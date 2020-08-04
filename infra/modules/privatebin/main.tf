locals {
  name_prefix = "${var.app}-${var.environment}"
  default_tags = merge(var.tags, {
    Application = var.app
    Environment = var.environment
  })
}

data "aws_region" "current" {}

data "aws_availability_zones" "this" {}

module "managed_policies" {
  source = "yukihira1992/managed-policies/aws"
  version = "0.1.36"
}
