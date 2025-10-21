terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "subnet_ids" {}
variable "sg_id" {}

resource "aws_lb" "main" {
  name               = "resilient-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_id]
  subnets            = var.subnet_ids

  tags = {
    Name = "resilient-alb"
  }
}

output "lb_dns" {
  value = aws_lb.main.dns_name
}

output "lb_name" {
  value = aws_lb.main.name
}

