####################################################################
# EC2 Security Group
####################################################################
# EC2 SecurityGroup for connect to SMM
resource "aws_security_group" "sg_ec2" {
  name   = "for connect to ssm"
  vpc_id = var.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = "${var.tag}-sg"
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
resource "aws_instance" "ec2" {
  ami                         = data.aws_ssm_parameter.amazonlinux_2023.value
  instance_type               = "t2.micro"
  availability_zone           = var.az
  vpc_security_group_ids      = [aws_security_group.sg_ec2.id]
  subnet_id                   = var.private_id
  associate_public_ip_address = false
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.profile.name
  tags = {
    Name = "${var.tag}-ec2"
  }
}

####################################################################
# EC2 IAM Role
####################################################################
# IAM Role & 信頼ポリシー
resource "aws_iam_role" "role" {
  name = "ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Session Manager用のPolicy
resource "aws_iam_role_policy_attachment" "policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.role.name
}

# Profile (roleをEC2にアタッチするため)
resource "aws_iam_instance_profile" "profile" {
  name = "ssm-profile"
  role = aws_iam_role.role.name
}
