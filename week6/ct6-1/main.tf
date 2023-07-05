module "network" {
  source = "./module/network"
  #rootディレクトリの変数を使用
  tag           = var.tag
  az-1a         = var.az-1a
  az-1c         = var.az-1c
  vpc_cidr      = var.vpc_cidr
  public_cidr   = var.public_cidr
  private1_cidr = var.private1_cidr
  private2_cidr = var.private2_cidr
  private3_cidr = var.private3_cidr
  all_cidr      = var.all
}

module "ec2" {
  source = "./module/ec2"

  #別のmoduleから変数を取得する場合は、module.module_name.{取得する変数}
  vpc_id           = module.network.vpc_id
  private1_id      = module.network.private1_id
  ssm_profile_name = module.IAM.ssm_profile_name
  tag              = var.tag
  az-1a            = var.az-1a
  vpc_cidr         = var.vpc_cidr
  public_cidr      = var.public_cidr
  private1_cidr    = var.private1_cidr
  all_cidr         = var.all
}

module "IAM" {
  source = "./module/IAM"
}

module "RDS" {
  source = "./module/RDS"

  az-1a         = var.az-1a
  az-1c         = var.az-1c
  vpc_id        = module.network.vpc_id
  tag           = var.tag
  private1_id   = module.network.private1_id
  private2_id   = module.network.private2_id
  private3_id   = module.network.private3_id
  private1_cidr = var.private1_cidr
  all_cidr      = var.all
}