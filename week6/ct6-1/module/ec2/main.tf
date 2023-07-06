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
# EIC security group
resource "aws_security_group" "sg_eic" {
  name = "for EIC"
  vpc_id = var.vpc_id

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr ,local.allowed-myip]
  }

  tags = {
    Name = "${var.tag}-eic"
  }
}

# EIC => EC2 security group
resource "aws_security_group" "eic_to_ec2" {
  name = "EIC to EC2"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.allowed-myip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = "${var.tag}-sg_eic_to_ec2"
  }
}

######################################################################################
# EC2 Instance Connect Endpoint
######################################################################################
# EIC 作成
resource "aws_ec2_instance_connect_endpoint" "eic" {
  subnet_id = var.private1_id
  security_group_ids = [aws_security_group.sg_eic.id]

  tags = {
    Name = "${var.tag}-eic"
  }
}

######################################################################################
# EC2
######################################################################################
# get AMI
data "aws_ssm_parameter" "amazonlinux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64" # x86_64
}

# EC2
resource "aws_instance" "ec2"{
  ami                         = data.aws_ssm_parameter.amazonlinux_2023.value
  instance_type               = "t2.micro"
  availability_zone           = var.az-1a
  vpc_security_group_ids      = [aws_security_group.eic_to_ec2.id]
  subnet_id                   = var.private1_id
  associate_public_ip_address = false
  key_name                    = var.key_name
  iam_instance_profile = var.ssm_profile_name
  tags = {
    Name = "${var.tag}-ec2"
  }
}
