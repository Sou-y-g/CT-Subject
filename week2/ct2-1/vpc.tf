######################################################################################
## Network 
######################################################################################
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

resource "aws_subnet" "public1" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public1_subnet_cidr
  availability_zone = var.availability_zone1a
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tag_prefix}public1-subnet"
  }
}

resource "aws_subnet" "public2" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public2_subnet_cidr
  availability_zone = var.availability_zone1c
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tag_prefix}public2-subnet"
  }
}

resource "aws_subnet" "private1" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private1_subnet_cidr
  availability_zone = var.availability_zone1a
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tag_prefix}private1-subnet"
  }
}

resource "aws_subnet" "private2" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private2_subnet_cidr
  availability_zone = var.availability_zone1a
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tag_prefix}private2-subnet"
  }
}

resource "aws_subnet" "private3" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private3_subnet_cidr
  availability_zone = var.availability_zone1c
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tag_prefix}private3-subnet"
  }
}

resource "aws_subnet" "private4" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private4_subnet_cidr
  availability_zone = var.availability_zone1c
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tag_prefix}private4-subnet"
  }
}

######################################################################################
# Route table
######################################################################################
#Route table Public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.tag_prefix}public-rt"
  }
}

#Route
resource "aws_route" "public" {
  destination_cidr_block = var.public_route_table
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.igw.id
}

#Route association
resource "aws_route_table_association" "public1" {
  subnet_id = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

######################################################################################
## network acl 
######################################################################################
# private1
resource "aws_network_acl" "private1" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/24"  
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 101
    action     = "allow"
    cidr_block = "10.0.2.0/24"  
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/24"  
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 101
    action     = "allow"
    cidr_block = "10.0.2.0/24"  
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.tag_prefix}private1-nacl"
  }
}

resource "aws_network_acl_association" "private1" {
  subnet_id = aws_subnet.private1.id
  network_acl_id = aws_network_acl.private1.id
}

#private2
resource "aws_network_acl" "private2" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.1.0/24"  
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.1.0/24"  
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.tag_prefix}private2-nacl"
  }
}

resource "aws_network_acl_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  network_acl_id = aws_network_acl.private2.id
}

# private3
resource "aws_network_acl" "private3" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.10.0/24"  
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 101
    action     = "allow"
    cidr_block = "10.0.12.0/24"  
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.10.0/24"  
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 101
    action     = "allow"
    cidr_block = "10.0.12.0/24"  
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.tag_prefix}private3-nacl"
  }
}

resource "aws_network_acl_association" "private3" {
  subnet_id = aws_subnet.private3.id
  network_acl_id = aws_network_acl.private3.id
}


#private4
resource "aws_network_acl" "private4" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.11.0/24"  
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.11.0/24"  
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.tag_prefix}private4-nacl"
  }
}

resource "aws_network_acl_association" "private4" {
  subnet_id      = aws_subnet.private4.id
  network_acl_id = aws_network_acl.private4.id
}