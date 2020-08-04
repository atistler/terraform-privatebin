variable "allowed_cidr_blocks" {
  type = list(string)
}

# ALB Rules
resource "aws_security_group" "lb" {
  name = "${local.name_prefix}-lb"
  description = "Allow connections from external resources while limiting connections from ${local.name_prefix}-lb to internal resources"
  vpc_id = module.vpc.vpc_id
  tags = local.default_tags
}
resource "aws_security_group_rule" "lb_ingress_https" {
  type = "ingress"
  description = "HTTPS"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = var.allowed_cidr_blocks
  security_group_id = aws_security_group.lb.id
}
resource "aws_security_group_rule" "lb_ingress_http" {
  type = "ingress"
  description = "HTTP"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = var.allowed_cidr_blocks
  security_group_id = aws_security_group.lb.id
}
resource "aws_security_group_rule" "lb_egress" {
  description = "Only allow SG ${local.name_prefix}-lb to connect to ${local.name_prefix}-task on port ${var.container_port}"
  type = "egress"
  from_port = var.container_port
  to_port = var.container_port
  protocol = "tcp"
  source_security_group_id = aws_security_group.task.id
  security_group_id = aws_security_group.lb.id
}

# Task rules
resource "aws_security_group" "task" {
  name = "${local.name_prefix}-task"
  description = "Limit connections from internal resources while allowing ${local.name_prefix}-task to connect to all external resources"
  vpc_id = module.vpc.vpc_id
  tags = local.default_tags
}
resource "aws_security_group_rule" "task_ingress" {
  description = "Only allow connections from SG ${local.name_prefix}-lb on port ${var.container_port}"
  security_group_id = aws_security_group.task.id
  type = "ingress"
  from_port = var.container_port
  to_port = var.container_port
  protocol = "tcp"
  source_security_group_id = aws_security_group.lb.id
}
resource "aws_security_group_rule" "task_egress" {
  description = "Allows task to establish connections to all resources"
  security_group_id = aws_security_group.task.id
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

# VPC Endpoint Rules
resource "aws_security_group" "vpc_endpoint" {
  name = "${local.name_prefix}-vpc-endpoint"
  description = "Allows access to VPC endpoints"
  vpc_id = module.vpc.vpc_id
  tags = local.default_tags
  ingress {
    description = "Only allow connections from SG ${local.name_prefix}-task on port 443"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = [aws_security_group.task.id]
  }
}

