variable "region" {
  description = "The region where to deploy the infrastructure"
  type        = string
  default     = "ap-northeast-1"
}

variable "tag" {
  description = "Prefix for the tags"
  default     = "ct-8"
}

variable "az" {
  description = "The availability zones1a to use"
  type        = string
  default     = "ap-northeast-1a"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_cidr" {
  description = "The CIDR block for the private1 subnet"
  type        = string
  default     = "10.0.1.0/24"
}