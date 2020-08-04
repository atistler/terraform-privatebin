# Create ECR repository
resource "aws_ecr_repository" "this" {
  name = local.name_prefix
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy = jsonencode({
    rules: [
      {
        rulePriority: 1,
        description: "Keep image deployed with tag latest",
        selection: {
          tagStatus: "tagged",
          tagPrefixList: ["latest"],
          countType: "imageCountMoreThan",
          countNumber: 1
        },
        action: {
          type: "expire"
        }
      },
      {
        rulePriority: 2,
        description: "Keep last 5 any images",
        selection: {
          tagStatus: "any",
          countType: "imageCountMoreThan",
          countNumber: 5
        },
        action: {
          type: "expire"
        }
      }
    ]
  })
}

# Build Docker image and push to ECR from folder: ./example-service-directory
module "ecr_docker_build" {
  source = "github.com/atistler/terraform-ecr-docker-build-module"
  dockerfile_folder = "${path.module}/"
  aws_region = data.aws_region.current.id
  ecr_repository_url = aws_ecr_repository.this.repository_url
  aws_profile = "zamboni-training"
}
