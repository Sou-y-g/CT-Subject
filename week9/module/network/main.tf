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

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.tag}-igw"
  }
}

######################################################################
# Public Subnet
######################################################################
# public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_cidr
  availability_zone       = var.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tag}-public-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.all_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.tag}-rt"
  }
}

#Route association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}