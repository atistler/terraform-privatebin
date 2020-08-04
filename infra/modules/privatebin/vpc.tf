variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}
variable "private_subnet_cidrs" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "public_subnet_cidrs" {
  type = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = local.name_prefix
  cidr = var.vpc_cidr
  azs = slice(data.aws_availability_zones.this.zone_ids, 0, length(var.private_subnet_cidrs))
  private_subnets = var.private_subnet_cidrs
  public_subnets = var.public_subnet_cidrs
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_ipv6 = true
  enable_nat_gateway = false
  enable_ecr_dkr_endpoint = true
  ecr_dkr_endpoint_private_dns_enabled = true
  ecr_dkr_endpoint_security_group_ids = [aws_security_group.vpc_endpoint.id]
  enable_ecr_api_endpoint = true
  ecr_api_endpoint_private_dns_enabled = true
  ecr_api_endpoint_security_group_ids = [aws_security_group.vpc_endpoint.id]
  enable_efs_endpoint = true
  efs_endpoint_private_dns_enabled = true
  efs_endpoint_security_group_ids = [aws_security_group.vpc_endpoint.id]
  enable_logs_endpoint = true
  logs_endpoint_private_dns_enabled = true
  logs_endpoint_security_group_ids = [aws_security_group.vpc_endpoint.id]
  enable_s3_endpoint = true

  tags = local.default_tags
  vpc_tags = local.default_tags
  vpc_endpoint_tags = local.default_tags
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
output "public_subnet_ids" {
  value = module.vpc.public_subnets
}
output "private_subnet_ids" {
  value = module.vpc.private_subnets
}
