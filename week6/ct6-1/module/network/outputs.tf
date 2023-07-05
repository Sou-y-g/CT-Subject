output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private1_id" {
  value = aws_subnet.private1.id
}

output "private2_id" {
  value = aws_subnet.private2.id
}

output "private3_id" {
  value = aws_subnet.private3.id
}