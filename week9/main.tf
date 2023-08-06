module "network" {
  source = "./module/network"

  tag         = var.tag
  az          = var.az
  vpc_cidr    = var.vpc_cidr
  public_cidr = var.public_cidr
  all_cidr = var.all_cidr
}

module "ecs" {
  source = "./module/ecs"

  ecs_instance_profile = module.iam.ecs_instance_profile
  ecs_task_execution_role = module.iam.ecs_task_execution_role
  vpc_id       = module.network.vpc_id
  public_id   = module.network.public_id
  tag          = var.tag
  az           = var.az
  vpc_cidr     = var.vpc_cidr
  all_cidr = var.all_cidr
}

module "ecr" {
  source = "./module/ecr"

  tag          = var.tag
}

module "iam" {
  source = "./module/iam"
}

module "cloudwatch" {
  source = "./module/cloudwatch"
}