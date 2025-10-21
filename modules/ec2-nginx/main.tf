######################
# Variáveis
######################

variable "region" {}
variable "ami_id" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "vpc_id" {}

provider "aws" {
  region = var.region
}

######################
# Security Group para NGINX
######################

resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg"
  description = "Permite acesso HTTP ao NGINX"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-sg"
  }
}

######################
# Instância EC2 com NGINX
######################

resource "aws_instance" "nginx" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install -y nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
  EOF

  tags = {
    Name = "nginx-${var.region}"
  }
}

