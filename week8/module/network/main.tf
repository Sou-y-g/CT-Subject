######################################################################
# NetWork
######################################################################
# VPC作成
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.tag}-vpc"
  }
}

######################################################################
# Private Subnet
######################################################################
# private subnet
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_cidr
  availability_zone       = var.az
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tag}-private-subnet"
  }
}

######################################################################
# VPC Endpoint Security Group
######################################################################
# Endpoint sg
resource "aws_security_group" "endpoint-sg" {
  name   = "for endpoint"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.tag}-endpoint-sg"
  }
}

######################################################################
# VPC Endpoint
######################################################################
#VPC_Endpoint x3(type:Interface)
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.endpoint-sg.id]
  subnet_ids          = [aws_subnet.private.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.tag}-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.endpoint-sg.id]
  subnet_ids          = [aws_subnet.private.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.tag}-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.endpoint-sg.id]
  subnet_ids          = [aws_subnet.private.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.tag}-vpc-endpoint"
  }
}