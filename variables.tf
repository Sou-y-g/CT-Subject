variable "region" {
  description = "The region where to deploy the infrastructure"
  type        = string
  default     = "ap-northeast-1"
}

variable "availability_zones" {
  description = "The availability zones to use"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  type        = list(string)
  default     = ["10.0.0.0/24","10.0.10.0/24"]
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  type        = list(string)
  default     = ["10.0.1.0/24","10.0.2.0/24","10.0.11.0/24","10.0.12.0/24"]
}


#Public Subnet ルートテーブル
#variable "route_tables_pbulic" {
#  description = "The rules for each route table"
#  type        = list(map(string))
#  default     = [
#    {
#      destination_cidr_block = "10.0.0.0/16"
#    }
#  ]
#}
#
###Private Subnet01 ルートテーブル => PublicSub, PrivateSub02
#variable "route_tables_private-01" {
#  description = "The rules for each route table"
#  type        = list(map(string))
#  default     = [
#    {
#      destination_cidr_block = "10.0.0.0/24"
#    },
#    {
#      destination_cidr_block = "10.0.2.0/24"
#    }
#  ]
#}
#
##Private Subnet02 ルートテーブル => PrivateSub01
#variable "route_tables_private-02" {
#  description = "The rules for each route table"
#  type        = list(map(string))
#  default     = [
#    {
#      destination_cidr_block = "10.0.1.0/24"
#    },
#  ]
#}
#
##Private Subnet03 ルートテーブル => PublicSub, PrivateSub04
#variable "route_tables_private-03" {
#  description = "The rules for each route table"
#  type        = list(map(string))
#  default     = [
#    {
#      destination_cidr_block = "10.0.10.0/24"
#    },
#    {
#      destination_cidr_block = "10.0.12.0/24"
#    }
#  ]
#}
#
##Private Subnet01 ルートテーブル
#variable "route_tables_private-04" {
#  description = "The rules for each route table"
#  type        = list(map(string))
#  default     = [
#    {
#      destination_cidr_block = "10.0.11.0/24"
#    }
#  ]
#}

variable "tag_prefix" {
  description = "Prefix for the tags"
  default     = "CloudTech-"
}