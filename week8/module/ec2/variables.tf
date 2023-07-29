variable "key_name" {
  description = "EC2 key"
  default     = "ct_key"
}

variable "tag" {}
variable "az" {}
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "private_cidr" {}
variable "private_id" {}
variable "all_cidr" {}