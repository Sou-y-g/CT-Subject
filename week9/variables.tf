variable "region" {
  description = "The region where to deploy the infrastructure"
  type        = string
  default     = "ap-northeast-1"
}

variable "tag" {
  description = "Prefix for the tags"
  default     = "ct-9"
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

variable "public_cidr" {
  description = "The CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "all_cidr" {
  description = "The CIDR block for all range"
  type        = string
  default     = "0.0.0.0/0"
}