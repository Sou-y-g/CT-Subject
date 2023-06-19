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

resource "aws_vpc_peering_connection" "peering" {
  peer_vpc_id = aws_vpc.vpc1.id
  vpc_id = aws_vpc.vpc2.id
  auto_accept = true

  tags = {
    Name = "${var.tag_prefix}vpcpeering"
  }
}

######################################################################################
# Route table
######################################################################################
#Route table for subnet1
resource "aws_route_table" "subnet1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "${var.tag_prefix}subnet1-rt"
  }
}

#Route
resource "aws_route" "subnet1" {
  destination_cidr_block = var.subnet1_route_table
  route_table_id = aws_route_table.subnet1.id
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

#Route association
resource "aws_route_table_association" "subnet1" {
  subnet_id = aws_subnet.private1.id
  route_table_id = aws_route_table.subnet1.id
}

#Route table for subnet2
resource "aws_route_table" "subnet2" {
  vpc_id = aws_vpc.vpc2.id

  tags = {
    Name = "${var.tag_prefix}subnet2-rt"
  }
}

#Route
resource "aws_route" "subnet2" {
  destination_cidr_block = var.subnet2_route_table
  route_table_id = aws_route_table.subnet2.id
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

#Route association
resource "aws_route_table_association" "subnet2" {
  subnet_id = aws_subnet.private2.id
  route_table_id = aws_route_table.subnet2.id
}

######################################################################################
# Security Group
######################################################################################
# subnet1 security group
resource "aws_security_group" "sg1" {
  name = "allow ICMP"
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "${var.tag_prefix}sg1"
  }
}

resource "aws_security_group_rule" "sg1_in" {
    type        = "ingress"
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["172.18.0.0/16"]

security_group_id = aws_security_group.sg1.id
}

# subnet2 security group
resource "aws_security_group" "sg2" {
  name = "allow ICMP"
  vpc_id = aws_vpc.vpc2.id
  tags = {
    Name = "${var.tag_prefix}sg2"
  }
}

resource "aws_security_group_rule" "sg2_in" {
    type        = "ingress"
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["10.0.0.0/16"]

security_group_id = aws_security_group.sg2.id
}

######################################################################################
# EC2
######################################################################################