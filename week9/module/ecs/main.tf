######################################################################################
# Security Group
######################################################################################
## get my ip
data "http" "ifconfig" {
  url = "http://ipv4.icanhazip.com/"
}

variable "allowed-myip" {
  default = null
}

locals {
  current-ip   = chomp(data.http.ifconfig.body)
  allowed-myip = (var.allowed-myip == null) ? "${local.current-ip}/32" : var.allowed-myip
}

####################################################################
# EIC security group
####################################################################
# EIC Endpointのセキュリティグループ
resource "aws_security_group" "sg_eic_endpoint" {
  name   = "for EIC Endpoint"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.tag}-eic-endpoint"
  }
}

# EC2へのアウトバウンド
resource "aws_security_group_rule" "sg_eic_endpoint" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.sg_eic_endpoint.id
  source_security_group_id = aws_security_group.sg_ec2.id
  }

# EC2のセキュリティグループ
resource "aws_security_group" "sg_ec2" {
  name   = "for EC2"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.tag}-sg-ec2"
  }
}

# EIC Endpointからのインバウンド
resource "aws_security_group_rule" "sg_ec2_in" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.sg_ec2.id
  source_security_group_id = aws_security_group.sg_eic_endpoint.id
  }

# myipからのssh許可
resource "aws_security_group_rule" "sg_ec2_ssh_in" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = [local.allowed-myip]
  security_group_id = aws_security_group.sg_ec2.id
  }

# myipからのhttp
resource "aws_security_group_rule" "sg_ec2_http_in" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = [local.allowed-myip]
  security_group_id = aws_security_group.sg_ec2.id
  }

# 外への通信 all ok
resource "aws_security_group_rule" "sg_ec2_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_ec2.id
  }

######################################################################################
# EC2 Instance Connect Endpoint
######################################################################################
# EIC 作成
resource "aws_ec2_instance_connect_endpoint" "eic" {
  subnet_id          = var.public_id
  security_group_ids = [aws_security_group.sg_eic_endpoint.id]

  tags = {
    Name = "${var.tag}-eic"
  }
}

######################################################################################
# ECS
######################################################################################
# クラスター
resource "aws_ecs_cluster" "cluster" {
  name = "${var.tag}-ecs-cluster"
}

# タスク定義
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${var.tag}-nginx"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      "name" : "${var.tag}-task-definitions",
      "image" : "nginx:latest",
      "image": "194641379830.dkr.ecr.ap-northeast-1.amazonaws.com/nginx:latest",
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : 80
          "hostPort"      : 80
          "protocol" : "tcp"
        }
      ]
    }
  ])
}

# サービス
resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1
  launch_type     = "EC2"
}

# ホストインスタンス
resource "aws_instance" "ecs_instance" {
  ami                         = "ami-0d4fecf0f502472a1"
  instance_type               = "t2.micro"
  subnet_id                   = var.public_id
  associate_public_ip_address = true
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.sg_ec2.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2-role.name

  user_data = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${var.tag}-ecs-cluster >> /etc/ecs/ecs.config
              EOF

  tags = {
    Name = "${var.tag}-ecs-instance"
  }

  depends_on = [aws_ecs_service.nginx]
}

#################################################
# IAM role
#################################################
# ec2用のrole
data "aws_iam_role" "ec2-role" {
  name = "ecsInstanceRole"
}

# EC2 IAM Role
resource "aws_iam_instance_profile" "ec2-role" {
  name = "ecs-instance-profile"
  role = data.aws_iam_role.ec2-role.name
}

# タスク定義ロール
# AssumeRole
data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs_task_execution_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

## ECRからイメージを取得するためのRole
#data "aws_iam_policy_document" "ecr_policy" {
#  statement {
#    sid    = "ECRPermissions"
#    effect = "Allow"
#
#    actions = [
#      "ecr:GetAuthorizationToken",
#      "ecr:BatchCheckLayerAvailability",
#      "ecr:GetDownloadUrlForLayer",
#      "ecr:GetRepositoryPolicy",
#      "ecr:DescribeRepositories",
#      "ecr:ListImages",
#      "ecr:DescribeImages",
#      "ecr:BatchGetImage",
#    ]
#
#    resources = ["*"]
#  }
#}
#
#resource "aws_iam_policy" "ecr_policy" {
#  name        = "ecr_policy"
#  description = "Policy to allow ECS to pull from ECR"
#  policy      = data.aws_iam_policy_document.ecr_policy.json
#}
#
#resource "aws_iam_role_policy_attachment" "ecr_policy_attachment" {
#  role       = aws_iam_role.ecs_task_execution_role.name
#  policy_arn = aws_iam_policy.ecr_policy.arn
#}

#################################################
# ECR
#################################################
# ECR作成
resource "aws_ecr_repository" "ecr" {
  name = "nginx"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.tag}-ecr"
  }
}