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
# security group
####################################################################
# EC2のセキュリティグループ
resource "aws_security_group" "sg_ec2" {
  name   = "for EC2"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.tag}-sg-ec2"
  }
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
  execution_role_arn = var.ecs_task_execution_role
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture = "X86_64"
  }

  container_definitions = jsonencode([
    {
      "name" : "${var.tag}-task-definitions",
      "image": "194641379830.dkr.ecr.ap-northeast-1.amazonaws.com/nginx:latest",
      #"image": "nginx",
      "essential" : true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "app",
          "awslogs-group": "/ecs/app"
        }
      }
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
  iam_instance_profile        = var.ecs_instance_profile

  user_data = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${var.tag}-ecs-cluster >> /etc/ecs/ecs.config
              EOF

  tags = {
    Name = "${var.tag}-ecs-instance"
  }

  depends_on = [aws_ecs_service.nginx]
}
