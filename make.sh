#!/bin/bash

# アプリケーション名を引数から取得
echo "what's your app name? :"
read APP_NAME

#providers.tfの作成
cat <<EOF > provider.tf
terraform {
  required_version = "1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.4.0"
    }
  }
}

provider "aws" {
  region  = var.region
}

EOF

# variables.tfの作成
cat << EOF > variables.tf
variable "region" {
  description = "The region where to deploy the infrastructure"
  type        = string
  default     = "ap-northeast-1"
}

variable "tag" {
  description = "Prefix for the tags"
  default     = "${APP_NAME}"
}

EOF

#root ディレクトリにファイルを作成
touch main.tf variables.tf outputs.tf

# ディレクトリを作成
mkdir -p module

# 各ディレクトリに.tfファイルを作成
for dir in module; do
  touch ${dir}/main.tf
  touch ${dir}/variables.tf
  touch ${dir}/outputs.tf
done
