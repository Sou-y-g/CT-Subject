terraform {
  #required_version = "1.5.0"
  required_version = "1.5.2"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "~> 5.4.0"
      version = "~> 5.6.2"
    }
  }
}

provider "aws" {
  region = var.region
}

