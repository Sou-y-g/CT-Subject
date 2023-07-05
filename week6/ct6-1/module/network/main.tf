######################################################################
# NetWork
######################################################################
# VPC作成
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.tag}-vpc"
  }
}

# InternetGateway作成
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.tag}-ig"
  }
}

######################################################################
# Public Subnet
######################################################################
# PublicSubnet作成
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.public_cidr
  availability_zone = var.az-1a
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tag}-public-subnet"
  }
}

# public route_table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.all_cidr
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "${var.tag}-public-rt"
  }
}

resource "aws_route_table_association" "public_rt" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

######################################################################
# Private Subnet
######################################################################
# private1 (for ec2)
resource "aws_subnet" "private1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private1_cidr
  availability_zone = var.az-1a
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tag}-private1-subnet"
  }
}

# private1 route_table
resource "aws_route_table" "private1_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.all_cidr
    gateway_id = aws_nat_gateway.ng.id
  }

  tags = {
    Name = "${var.tag}-private1-rt"
  }
  
}

resource "aws_route_table_association" "routetable1" {
  route_table_id = aws_route_table.private1_rt.id
  subnet_id = aws_subnet.private1.id
}

# private2 (for RDS)
resource "aws_subnet" "private2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private2_cidr
  availability_zone = var.az-1a
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tag}-private2-subnet"
  }
}

# private3 (for RDS MultiAZ)
resource "aws_subnet" "private3" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private3_cidr
  availability_zone = var.az-1c
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tag}-private3-subnet"
  }
}

######################################################################
# NatGateway
######################################################################
# EIP作成
resource "aws_eip" "eip" {
  domain = "vpc"

  tags = {
    Name = "${var.tag}-eip"
  }
}

# NatGateway作成
resource "aws_nat_gateway" "ng" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.public.id
  
  tags = {
    Name = "${var.tag}-ng"
  }
}