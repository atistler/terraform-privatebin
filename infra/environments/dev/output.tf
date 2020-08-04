output "ecs_cluster_id" {
  value = module.privatebin.ecs_cluster_id
}
output "ecs_service_id" {
  value = module.privatebin.ecs_service_id
}
output "ecs_task_definition" {
  value = module.privatebin.ecs_task_definition
}
output "ecs_task_iam_role_arn" {
  value = module.privatebin.ecs_task_iam_role_arn
}
output "ecs_execution_iam_role_arn" {
  value = module.privatebin.ecs_execution_iam_role_arn
}
output "alb_dns_name" {
  value = module.privatebin.alb_dns_name
}
output "alb_access_log_bucket" {
  value = module.privatebin.alb_access_log_bucket
}
output "vpc_id" {
  value = module.privatebin.vpc_id
}
output "public_subnet_ids" {
  value = module.privatebin.public_subnet_ids
}
output "private_subnet_ids" {
  value = module.privatebin.private_subnet_ids
}
output "route53_nameservers" {
  value = module.privatebin.route53_nameservers
}
output "certificate_arn" {
  value = module.privatebin.certificate_arn
}
