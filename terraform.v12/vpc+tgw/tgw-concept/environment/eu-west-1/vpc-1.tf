provider "aws" {
  region = "eu-west-1"
}

#####
# Vpc
#####

module "vpc" {
  source = "../../modules/aws-vpc"

  vpc-location                        = "Ireland"
  namespace                           = "cloudgeeksca-tgw"
  name                                = "vpc-1-eu-west-1"
  stage                               = "dev"
  map_public_ip_on_launch             = "false"
  total-nat-gateway-required          = "1"
  create_database_subnet_group        = "false"
  vpc-cidr                            = "10.128.0.0/16"
  vpc-public-subnet-cidr              = ["10.128.1.0/24","10.128.2.0/24"]
  vpc-private-subnet-cidr             = ["10.128.4.0/24","10.128.5.0/24"]
  vpc-database_subnets-cidr           = ["10.128.7.0/24", "10.128.8.0/24"]
}

# VPC-1-SG


module "sg-tgw" {
  source = "../../modules/aws-sg-tgw"
  security_group_name = "TGW-sg"
  vpc_id = module.vpc.vpc-id

  # Rule-1
  ingress-rule-1-from-port = 0
  ingress-rule-1-to-port = 0
  ingress-rule-1-protocol = "-1"
  ingress-rule-1-cidrs = ["10.1.0.0/16"]
  ingress-rule-1-description = "Allow Traffic From VPC2-us-east-1"

  # Rule-4
  ingress-rule-4-from-port   = 0
  ingress-rule-4-to-port     = 0
  ingress-rule-4-protocol    = "-1"
  ingress-rule-4-cidrs       = ["10.130.0.0/16"]
  ingress-rule-4-description = "Allow Traffic From VPC1-eu-central-1"


  # Rule-3
  ingress-rule-3-from-port   = 0
  ingress-rule-3-to-port     = 0
  ingress-rule-3-protocol    = "-1"
  ingress-rule-3-cidrs       = ["10.128.0.0/16"]
  ingress-rule-3-description = "ALL Internal Traffic Allowed"

}




# EC2-Private
module "ec2-tgw" {
  source                        = "../../modules/aws-ec2"
  namespace                     = "cloudgeeksca-tgw"
  stage                         = "dev"
  name                          = "ec2-vpc-1-eu-west-1"
  key_name                      = "transit-gateway-vpc-1"
  public_key                    = file("../../modules/secrets/transit-gateway.pub")
  instance_count                = 1
  ami                           = "ami-0d712b3e6e1f798ef"
  instance_type                 = "t3a.small"
  associate_public_ip_address   = "false"
  root_volume_size              = 8
  subnet_ids                    = module.vpc.private-subnet-ids
  vpc_security_group_ids        = [module.sg-tgw.aws_security_group]

}






