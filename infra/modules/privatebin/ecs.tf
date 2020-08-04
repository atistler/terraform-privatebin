variable "container_port" {
  type = number
  default = 8080
}
variable "container_image" {
  type = string
  default = "privatebin/nginx-fpm-alpine"
}

resource "aws_ecs_cluster" "this" {
  name = local.name_prefix
  setting {
    name = "containerInsights"
    value = "enabled"
  }
  tags = local.default_tags
}

resource "aws_ecs_task_definition" "this" {
  family = local.name_prefix
  execution_role_arn = module.ecs_execution_role.this_iam_role_arn
  task_role_arn = module.ecs_task_role.this_iam_role_arn
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
  tags = local.default_tags

  container_definitions = jsonencode([
    {
      name: local.name_prefix,
      image: aws_ecr_repository.this.repository_url,
      essential: true,
      portMappings: [
        {
          protocol: "tcp",
          containerPort: var.container_port,
          hostPort: var.container_port
        }
      ],
      logConfiguration: {
        logDriver: "awslogs",
        options: {
          awslogs-group: "/fargate/services/${local.name_prefix}",
          awslogs-region: data.aws_region.current.id,
          awslogs-stream-prefix: "ecs"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/fargate/services/${local.name_prefix}"
  retention_in_days = 90
  tags = local.default_tags
}

resource "aws_ecs_service" "this" {
  name = local.name_prefix
  cluster = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.family
  desired_count = 1
  launch_type = "FARGATE"
  network_configuration {
    security_groups = [aws_security_group.task.id]
    subnets = module.vpc.private_subnets
  }
  load_balancer {
    target_group_arn = aws_alb_target_group.this.arn
    container_name = local.name_prefix
    container_port = var.container_port
  }
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.this.id
}
output "ecs_service_id" {
  value = aws_ecs_service.this.id
}
output "ecs_task_definition" {
  value = aws_ecs_task_definition.this.id
}



