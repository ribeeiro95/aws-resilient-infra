output "public_ip" {
  value = aws_instance.nginx.public_ip
}

output "instance_id" {
  value = aws_instance.nginx.id
}
