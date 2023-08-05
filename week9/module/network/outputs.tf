output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_id" {
  value = aws_subnet.public.id
}
