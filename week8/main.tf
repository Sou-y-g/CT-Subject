module "network" {
  source = "./module/network"
  #rootディレクトリの変数を使用
  region       = var.region
  tag          = var.tag
  az           = var.az
  vpc_cidr     = var.vpc_cidr
  private_cidr = var.private_cidr
}

module "ec2" {
  source = "./module/ec2"

  #別のmoduleから変数を取得する場合は、module.module_name.{取得する変数}
  vpc_id       = module.network.vpc_id
  private_id   = module.network.private_id
  tag          = var.tag
  az           = var.az
  vpc_cidr     = var.vpc_cidr
  private_cidr = var.private_cidr
}