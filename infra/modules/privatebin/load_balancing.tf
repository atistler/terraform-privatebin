# The path to the health check for the load balancer to know if the container(s) are ready
variable "alb_health_check_path" {
  type = string
  default = "/"
}

resource "aws_alb" "this" {
  name = local.name_prefix
  internal = false
  subnets = module.vpc.public_subnets
  security_groups = [aws_security_group.lb.id]
  tags = local.default_tags
  # enable access logs in order to get support from aws
  access_logs {
    enabled = true
    bucket = aws_s3_bucket.lb_access_logs.bucket
  }
}

resource "aws_alb_target_group" "this" {
  name = local.name_prefix
  port = 8080
  protocol = "HTTP"
  vpc_id = module.vpc.vpc_id
  target_type = "ip"
  # The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused
  deregistration_delay = 30

  health_check {
    protocol = "HTTP"
    port = "8080"
    path = var.alb_health_check_path
    # What HTTP response code to listen for
    matcher = 200
    # How often to check the liveliness of the container
    interval = 30
    # How long to wait for the response on the health check path
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
  tags = local.default_tags
}

data "aws_elb_service_account" "this" {}

# bucket for storing ALB access logs
resource "aws_s3_bucket" "lb_access_logs" {
  bucket = "${local.name_prefix}-lb-access-logs"
  acl = "private"
  tags = local.default_tags
  force_destroy = true

  lifecycle_rule {
    id = "cleanup"
    enabled = true
    abort_incomplete_multipart_upload_days = 1
    prefix = ""

    expiration {
      days = 7
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

data "aws_iam_policy_document" "lb_access_logs" {
  statement {
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      aws_s3_bucket.lb_access_logs.arn, "${aws_s3_bucket.lb_access_logs.arn}/*"
    ]
    principals {
      identifiers = [data.aws_elb_service_account.this.arn]
      type = "AWS"
    }
  }
}
# give load balancing service access to the bucket
resource "aws_s3_bucket_policy" "lb_access_logs" {
  bucket = aws_s3_bucket.lb_access_logs.id
  policy = data.aws_iam_policy_document.lb_access_logs.json
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.this.id
  port = 443
  protocol = "HTTPS"
  certificate_arn = aws_acm_certificate.this.arn
  ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.this.id
  }
}

resource "aws_alb_listener" "redirect_http_to_https" {
  load_balancer_arn = aws_alb.this.id
  port = 80
  protocol = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port = 443
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# The load balancer DNS name
output "alb_dns_name" {
  value = aws_alb.this.dns_name
}
output "alb_access_log_bucket" {
  value = aws_s3_bucket.lb_access_logs.bucket
}


