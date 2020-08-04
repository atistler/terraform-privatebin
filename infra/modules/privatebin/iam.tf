module "ecs_execution_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "2.3.0"
  role_requires_mfa = false
  role_name = "${local.name_prefix}-ecs-execution"
  create_role = true
  trusted_role_services = ["ecs-tasks.amazonaws.com"]
  custom_role_policy_arns = [
    module.managed_policies.AmazonECSTaskExecutionRolePolicy
  ]
  tags = local.default_tags
}

data "aws_iam_policy_document" "ecs_task" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:DescribeClusters",
    ]
    resources = [
      aws_ecs_cluster.this.arn,
    ]
  }
}

resource "aws_iam_policy" "ecs_task" {
  name = "${local.name_prefix}-ecs-task"
  policy = data.aws_iam_policy_document.ecs_task.json
}

module "ecs_task_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "2.3.0"
  role_requires_mfa = false
  role_name = "${local.name_prefix}-ecs-task"
  create_role = true
  trusted_role_services = ["ecs-tasks.amazonaws.com"]
  custom_role_policy_arns = [aws_iam_policy.ecs_task.arn]
  tags = local.default_tags
}

output "ecs_task_iam_role_arn" {
  value = module.ecs_task_role.this_iam_role_arn
}

output "ecs_execution_iam_role_arn" {
  value = module.ecs_execution_role.this_iam_role_arn
}
