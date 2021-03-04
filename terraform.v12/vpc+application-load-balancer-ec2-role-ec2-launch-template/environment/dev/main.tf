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

module "rabbitmq-sg" {
  source              = "../../modules/aws-sg-cidr"
  namespace           = "cloudgeeks.ca"
  stage               = "dev"
  name                = "rabbitmq"
  tcp_ports           = "80,443"
  cidrs               = ["0.0.0.0/0"]
  security_group_name = "rabbitmq"
  vpc_id              = module.vpc.vpc-id
}

module "alb-sg" {
  source              = "../../modules/aws-sg-cidr"
  namespace           = "cloudgeeks.ca"
  stage               = "dev"
  name                = "ALB"
  tcp_ports           = "80,443"
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
  certificate-arn          = "arn:aws:acm:us-east-1:249147895833:certificate/13c592f9-2d47-4607-ba5a-a7edb129c5f7"
  target-group-arn         = module.alb-tg.target-group-arn
}

module "rabbitmq-ec2-launch-template" {
  source = "../../modules/aws-asg/aws-ec2-lauch-template"

  aws-launch-template-name            = "rabbitmq-ec2-launch-template"
  aws-launch-template-description     = "rabbitmq ec2 launch template"
  ebs-volume-size                     = 20
  instance-profile-arn                = "arn:aws:iam::249147895833:instance-profile/aws-iam-instance-profile"
  ec2-ami-id                          = "ami-0915bcb5fa77e4892"
  ec2-instance-type                   = "t3a.small"
  security-group-ids                  = [module.rabbitmq-sg.aws_security_group_default]
  ec2-user-data                       = filebase64("../../modules/aws-asg/aws-ec2-lauch-template/user-data.sh")
  # Note: Mentioned below tag must be rabbitmq  
  ec2-tag                             = "rabbitmq"

}





