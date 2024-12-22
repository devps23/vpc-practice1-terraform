module "app" {
  source = "./modules/app"
  instance_type="t2.micro"
  env = var.env
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.frontend_subnets
}
module "vpc1"{
  source = "./modules/vpc"
  vpc_id = var.vpc_id
  env = var.env
  availability_zones = var.availability_zones
  frontend_subnets = var.frontend_subnets
  backend_subnets = var.backend_subnets
  db_subnets = var.db_subnets
  default_cidr_block=var.default_cidr_block
  default_vpc_id = var.default_vpc_id
  public_subnets = var.public_subnets
}