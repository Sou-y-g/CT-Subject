output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_id" {
  value = aws_subnet.private.id
}
