variable "region" {
  description = "The region where to deploy the infrastructure"
  type        = string
  default     = "ap-northeast-1"
}

variable "availability_zone1a" {
  description = "The availability zones1a to use"
  type        = string
  default     ="ap-northeast-1a"
}

variable "vpc1_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private1_subnet_cidr" {
  description = "The CIDR block for the private1 subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "vpc2_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "172.18.0.0/16"
}

variable "private2_subnet_cidr" {
  description = "The CIDR block for the private2 subnet"
  type        = string
  default     = "172.18.1.0/24"
}

variable "subnet1_route_table" {
  description = "The CIDR Block for private subnet route table"
  type = string
  default = "172.18.0.0/16"
}

variable "subnet2_route_table" {
  description = "The CIDR Block for private subnet route table"
  type = string
  default = "10.0.0.0/16"
}

variable "tag_prefix" {
  description = "Prefix for the tags"
  default     = "CloudTech-2-2-"
}