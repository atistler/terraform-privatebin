module "privatebin" {
  source = "../../modules/privatebin"
  domain_name = "duck79.chickenkiller.com"
  allowed_cidr_blocks = ["0.0.0.0/0"]
}
