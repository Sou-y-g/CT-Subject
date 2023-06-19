######################################################################################
## Network 
######################################################################################
resource "aws_vpc" "vpc1" {
  cidr_block = var.vpc1_cidr
  tags = {
    Name = "${var.tag_prefix}vpc1"
  }
}

resource "aws_subnet" "private1" {
  vpc_id = aws_vpc.vpc1.id
  cidr_block = var.private1_subnet_cidr
  availability_zone = var.availability_zone1a
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tag_prefix}private1-subnet"
  }
}

resource "aws_vpc" "vpc2" {
  cidr_block = var.vpc2_cidr
  tags = {
    Name = "${var.tag_prefix}vpc2"
  }
}

resource "aws_subnet" "private2" {
  vpc_id = aws_vpc.vpc2.id
  cidr_block = var.private2_subnet_cidr
  availability_zone = var.availability_zone1a
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tag_prefix}private2-subnet"
  }
}

######################################################################################
# Route table
######################################################################################
#Route table Public
#resource "aws_route_table" "public" {
#  vpc_id = aws_vpc.main.id
#
#  tags = {
#    Name = "${var.tag_prefix}public-rt"
#  }
#}
#
##Route
#resource "aws_route" "public" {
#  destination_cidr_block = var.public_route_table
#  route_table_id = aws_route_table.public.id
##  gateway_id = aws_internet_gateway.igw.id
#}
#
##Route association
#resource "aws_route_table_association" "public1" {
#  subnet_id = aws_subnet.public1.id
#  route_table_id = aws_route_table.public.id
#}
#
#resource "aws_route_table_association" "public2" {
#  subnet_id = aws_subnet.public2.id
#  route_table_id = aws_route_table.public.id
#}
#