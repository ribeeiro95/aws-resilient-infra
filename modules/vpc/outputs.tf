output "public_subnets" {
  value = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}
output "vpc_id" {
  value = aws_vpc.main.id
}
