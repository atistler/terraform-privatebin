variable "domain_name" {
  type = string
}
resource "aws_route53_zone" "this" {
  name = var.domain_name
}

resource "aws_route53_record" "this" {
  name = var.domain_name
  type = "A"
  zone_id = aws_route53_zone.this.id

  alias {
    name = aws_alb.this.dns_name
    zone_id = aws_alb.this.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "this" {
  domain_name = var.domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  name = aws_acm_certificate.this.domain_validation_options.0.resource_record_name
  type = aws_acm_certificate.this.domain_validation_options.0.resource_record_type
  records = [aws_acm_certificate.this.domain_validation_options.0.resource_record_value]
  zone_id = aws_route53_zone.this.zone_id
  ttl = 60
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = aws_acm_certificate.this.arn
  validation_record_fqdns = [aws_route53_record.validation.fqdn]
}

output "route53_nameservers" {
  value = aws_route53_zone.this.name_servers
}
output "certificate_arn" {
  value = aws_acm_certificate.this.arn
}
