variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "ami_id_east" {}
variable "ami_id_west" {}
variable "instance_type" {}

variable "route53_zone_id" {
  description = "ID da zona hospedada no Route 53"
  type        = string
}

variable "lb_zone_id" {
  description = "ID da zona do Load Balancer (geralmente fixo por região)"
  type        = string
}

variable "alb_name" {
  description = "Nome do Load Balancer"
  type        = string
}
