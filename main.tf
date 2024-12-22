# module "app" {
#   source = "./modules/app"
#   instance_type="t2.micro"
#   env = var.env
#   subnets = var.frontend_subnets
#   vpc_id = var.vpc_id
# }
module "vpc"{
  source = "./modules/vpc"
  vpc_id = var.vpc_id
  env = var.env
  availability_zones = var.availability_zones
  frontend_subnets = var.frontend_subnets
  backend_subnets = var.backend_subnets
  db_subnets = var.db_subnets
  default_vpc_id=var.default_vpc_id
}