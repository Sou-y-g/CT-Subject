variable "key_name" {
  description = "EC2 key"
  default = "ct_key"
}

variable "vpc_id" {}
variable "public_id" {}
variable "tag" {}
variable "az" {}
variable "vpc_cidr" {}
variable "all_cidr" {}
variable "ecs_instance_profile" {}
variable "ecs_task_execution_role" {}