locals {
  common_tags = {
    Project     = "multi-az-vpc-alb-asg"
    Environment = "dev"
    ManagedBy   = "terraform"
    CostMode    = var.enable_nat_gateway ? "paid-nat-enabled" : "cost-safe-nat-disabled"
  }

  app_subnet_ids = var.place_instances_in_private_subnets ? module.network.private_subnet_ids : module.network.public_subnet_ids
}

module "network" {
  source             = "../../modules/network"
  name               = var.name
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  enable_nat_gateway = var.enable_nat_gateway
  tags               = local.common_tags
}

module "security" {
  source     = "../../modules/security"
  name       = var.name
  vpc_id     = module.network.vpc_id
  app_port   = var.app_port
  enable_ssh = var.enable_ssh
  ssh_cidr   = var.ssh_cidr
  tags       = local.common_tags
}

module "alb" {
  source                = "../../modules/alb"
  name                  = var.name
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  app_port              = var.app_port
  tags                  = local.common_tags
}

module "compute" {
  source                = "../../modules/compute"
  name                  = var.name
  subnet_ids            = local.app_subnet_ids
  app_security_group_id = module.security.app_security_group_id
  target_group_arn      = module.alb.target_group_arn
  instance_type         = var.instance_type
  app_port              = var.app_port
  desired_capacity      = var.desired_capacity
  min_size              = var.min_size
  max_size              = var.max_size
  tags                  = local.common_tags
}
