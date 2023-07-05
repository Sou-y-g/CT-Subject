variable "key_name" {
  description = "EC2 key"
  default = "ct_key"
}

variable "vpc_id" {}
variable "private1_id" {}
variable "tag" {}
variable "az-1a" {}
variable "ssm_profile_name" {}
variable "vpc_cidr" {}
variable "public_cidr" {}
variable "private1_cidr" {}
variable "all_cidr" {}