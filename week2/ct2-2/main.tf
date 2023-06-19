######################################################################################
## Network 
######################################################################################
resource "aws_vpc" "vpc1" {
  cidr_block = var.vpc1_cidr
  #enable_dns_hostnames = true
  #enable_dns_support = true

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
  #enable_dns_hostnames = true
  #enable_dns_support = true

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
  peer_vpc_id = aws_vpc.vpc2.id
  vpc_id = aws_vpc.vpc1.id
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

resource "aws_security_group_rule" "sg1_out" {
    type        = "egress"
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

resource "aws_security_group_rule" "sg2_out" {
    type        = "egress"
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["10.0.0.0/16"]

    security_group_id = aws_security_group.sg2.id
}

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

# EIC security group
resource "aws_security_group" "sg_eic" {
  name = "for EIC"
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "${var.tag_prefix}sg_eic"
  }
}

resource "aws_security_group_rule" "sg_eic" {
    type        = "egress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16", local.allowed-myip]

    security_group_id = aws_security_group.sg_eic.id
}

# EIC => EC2 security group
resource "aws_security_group" "eic_to_ec2" {
  name = "EIC to EC2"
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "${var.tag_prefix}sg_eic_to_ec2"
  }
}

resource "aws_security_group_rule" "eic_to_ec2_in" {
    type        = "ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    source_security_group_id = aws_security_group.sg_eic.id #送信元がsourceで引数として宛先のsecurity group idが必要
    security_group_id = aws_security_group.eic_to_ec2.id
}

resource "aws_security_group_rule" "eic_to_ec2_out" {
    type        = "egress"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    source_security_group_id = aws_security_group.sg_eic.id #送信元がsourceで引数として宛先のsecurity group idが必要
    security_group_id = aws_security_group.eic_to_ec2.id
}

######################################################################################
# EC2
######################################################################################
# get AMI
data "aws_ssm_parameter" "amazonlinux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64" # x86_64
}

# EC2 for subnet1
resource "aws_instance" "ec2-1"{
  ami                         = data.aws_ssm_parameter.amazonlinux_2023.value
  instance_type               = "t2.micro"
  availability_zone           = var.availability_zone1a
  vpc_security_group_ids      = [aws_security_group.sg1.id, aws_security_group.eic_to_ec2.id]
  subnet_id                   = aws_subnet.private1.id
  associate_public_ip_address = false
  key_name                    = var.key_name
  tags = {
    Name = "${var.tag_prefix}ec2-1"
  }
}

# EC2 for subnet2
resource "aws_instance" "ec2-2"{
  ami                         = data.aws_ssm_parameter.amazonlinux_2023.value
  instance_type               = "t2.micro"
  availability_zone           = var.availability_zone1a
  vpc_security_group_ids      = [aws_security_group.sg2.id]
  subnet_id                   = aws_subnet.private2.id
  associate_public_ip_address = false
  key_name                    = var.key_name
  tags = {
    Name = "${var.tag_prefix}ec2-2"
  }
}