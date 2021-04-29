output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_public" {
  value = [for v in aws_subnet.public_subnet: v.id]
}

output "subnet_private" {
  value = [for v in aws_subnet.private_subnet: v.id]
}

output "sg_alb" {
  value = aws_security_group.alb
}

output "sg_pl" {
  value = aws_security_group.private_link
}
