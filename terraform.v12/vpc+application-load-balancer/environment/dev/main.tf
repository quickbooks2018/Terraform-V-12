provider "aws" {
  region = "us-east-1"
}

#####
# Vpc
#####

module "vpc" {
  source = "../../modules/aws-vpc"

  vpc-location                        = "Virginia"
  namespace                           = "cloudgeeks.ca"
  name                                = "vpc"
  stage                               = "dev"
  map_public_ip_on_launch             = "true"
  total-nat-gateway-required          = "1"
  create_database_subnet_group        = "false"
  vpc-cidr                            = "10.11.0.0/16"
  vpc-public-subnet-cidr              = ["10.11.1.0/24","10.11.2.0/24"]
  vpc-private-subnet-cidr             = ["10.11.4.0/24","10.11.5.0/24"]
  vpc-database_subnets-cidr           = ["10.11.7.0/24", "10.11.8.0/24"]
}

module "alb-sg" {
  source              = "../../modules/aws-sg-cidr"
  namespace           = "cloudgeeks.ca"
  stage               = "dev"
  name                = "ALB"
  tcp_ports           = "80,443,8080"
  cidrs               = ["0.0.0.0/0"]
  security_group_name = "Application-LoadBalancer"
  vpc_id              = module.vpc.vpc-id
}

module "alb-ref" {
  source                  = "../../modules/aws-sg-ref-v2"
  namespace               = "cloudgeeks.ca"
  stage                   = "dev"
  name                    = "ALB-Ref"
  tcp_ports               = "80,443"
  ref_security_groups_ids = [module.alb-sg.aws_security_group_default,module.alb-sg.aws_security_group_default]
  security_group_name     = "ALB-Ref"
  vpc_id                  = module.vpc.vpc-id
}

module "alb-tg" {
  source = "../../modules/aws-alb-tg"
  #Application Load Balancer Target Group
  alb-tg-name               = "cloudgeeks-tg"
  target-group-port         = "80"
  target-group-protocol     = "HTTP"
  vpc-id                    = module.vpc.vpc-id
}

module "alb" {
  source = "../../modules/aws-alb"
  alb-name                 = "cloudgeeks-alb"
  internal                 = "false"
  alb-sg                   = module.alb-sg.aws_security_group_default
  alb-subnets              = module.vpc.public-subnet-ids
  alb-tag                  = "cloudgeeks-alb"
  certificate-arn          = "arn:aws:acm:us-east-1:634167607583:certificate/504fae29-b3da-433d-8dc5-3d7a9b9e02d7"
  target-group-arn         = module.alb-tg.target-group-arn
}





