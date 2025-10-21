terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "aws" {
  alias      = "west"
  region     = "us-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "vpc_us_east" {
  source = "./modules/vpc"
  az_1   = "us-east-1a"
  az_2   = "us-east-1b"
}

module "vpc_us_west" {
  source = "./modules/vpc"
  providers = {
    aws = aws.west
  }
  az_1 = "us-west-2a"
  az_2 = "us-west-2b"
}

module "web_us_east" {
  source         = "./modules/ec2-nginx"
  region         = "us-east-1"
  ami_id         = var.ami_id_east
  instance_type  = var.instance_type
  subnet_id      = module.vpc_us_east.public_subnets[0]
  vpc_id         = module.vpc_us_east.vpc_id
}

module "web_us_west" {
  source         = "./modules/ec2-nginx"
  region         = "us-west-2"
  ami_id         = var.ami_id_west
  instance_type  = var.instance_type
  subnet_id      = module.vpc_us_west.public_subnets[0]
  vpc_id         = module.vpc_us_west.vpc_id
}

module "alb_us_east" {
  source     = "./modules/alb"
  subnet_ids = module.vpc_us_east.public_subnets
  sg_id      = module.vpc_us_east.alb_sg_id
  alb_name   = "resilient-alb-east"
}

module "alb_us_west" {
  source     = "./modules/alb"
  subnet_ids = module.vpc_us_west.public_subnets
  sg_id      = module.vpc_us_west.alb_sg_id
  alb_name   = "resilient-alb-west"
  providers = {
    aws = aws.west
  }
}

module "route53" {
  source            = "./modules/route53"
  zone_id           = var.route53_zone_id
  lb_zone_id        = var.lb_zone_id
  primary_lb_dns    = module.alb_us_east.lb_dns
  secondary_lb_dns  = module.alb_us_west.lb_dns
}

module "monitoring_us_east" {
  source   = "./modules/monitoring"
  alb_name = module.alb_us_east.lb_name
}

module "monitoring_us_west" {
  source   = "./modules/monitoring"
  alb_name = module.alb_us_west.lb_name
  providers = {
    aws = aws.west
  }
}
