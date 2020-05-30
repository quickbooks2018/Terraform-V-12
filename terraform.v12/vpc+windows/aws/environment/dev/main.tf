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
  stage                               = "windows-dev"
  map_public_ip_on_launch             = "true"
  total-nat-gateway-required          = "1"
  create_database_subnet_group        = "false"
  vpc-cidr                            = "10.20.0.0/16"
  vpc-public-subnet-cidr              = ["10.20.1.0/24","10.20.2.0/24","10.20.3.0/24","10.20.4.0/24"]
  vpc-private-subnet-cidr             = ["10.20.6.0/24","10.20.7.0/24"]
  vpc-database_subnets-cidr           = ["10.20.8.0/24", "10.20.9.0/24"]
}


module "sg1" {
  source              = "../../modules/aws-sg-cidr"
  namespace           = "cloudgeeks.ca"
  stage               = "dev"
  name                = "windows"
  tcp_ports           = "3389"
  cidrs               = ["111.119.187.3/32"]
  security_group_name = "windows"
  vpc_id              = module.vpc.vpc-id
}

module "sg2" {
  source                  = "../../modules/aws-sg-ref-v2"
  namespace               = "cloudgeeks.ca"
  stage                   = "dev"
  name                    = "windows-Ref"
  tcp_ports               = "3389,80,443"
  ref_security_groups_ids = [module.sg1.aws_security_group_default,module.sg1.aws_security_group_default,module.sg1.aws_security_group_default]
  security_group_name     = "windows-Ref"
  vpc_id                  = module.vpc.vpc-id
}


module "ec2-keypair" {
  source = "../../modules/aws-ec2-keypair"
  key-name      = "windows"
  public-key    = file("../../modules/secrets/windows.pub")
}

module "ec2-windows" {
  source                        = "../../modules/aws-ec2"
  namespace                     = "cloudgeeks.ca"
  stage                         = "dev"
  name                          = "windows"
  key_name                      = "windows"
  user_data                     = file("../../modules/aws-ec2/user-data/windows/user-data")
  instance_count                = 4
  ami                           = "ami-0cc5ea3dde5301489"
  instance_type                 = "t3a.medium"
  associate_public_ip_address   = "true"
  root_volume_size              = 35
  subnet_ids                    = module.vpc.public-subnet-ids
  vpc_security_group_ids        = [module.sg1.aws_security_group_default]

}

