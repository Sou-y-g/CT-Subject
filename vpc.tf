resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.tag_prefix}vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.tag_prefix}ig"
  }
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true
  tags = {
    Name = "${var.tag_prefix}public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone       = count.index < 2 ? var.availability_zones[0] : var.availability_zones[1]

  map_public_ip_on_launch = false
  tags = {
    Name = "${var.tag_prefix}private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public-rt" {
  destination_cidr_block    = "0.0.0.0/24"
}