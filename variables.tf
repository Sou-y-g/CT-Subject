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

variable "availability_zone1c" {
  description = "The availability zones1c to use"
  type        = string
  default     = "ap-northeast-1c"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public1_subnet_cidr" {
  description = "The CIDR block for the public1 subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "public2_subnet_cidr" {
  description = "The CIDR block for the public2 subnet"
  type        = string
  default     = "10.0.10.0/24"
}

variable "private1_subnet_cidr" {
  description = "The CIDR block for the public1 subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private2_subnet_cidr" {
  description = "The CIDR block for the public2 subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private3_subnet_cidr" {
  description = "The CIDR block for the public3 subnet"
  type        = string
  default     = "10.0.11.0/24"
}

variable "private4_subnet_cidr" {
  description = "The CIDR block for the public4 subnet"
  type        = string
  default     = "10.0.12.0/24"
}

variable "public_route_table" {
  description = "The CIDR Block for public subnet route table"
  type = string
  default = "0.0.0.0/0"
}

variable "tag_prefix" {
  description = "Prefix for the tags"
  default     = "CloudTech-"
}