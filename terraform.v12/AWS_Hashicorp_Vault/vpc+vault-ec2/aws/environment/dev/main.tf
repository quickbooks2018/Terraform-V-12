provider "aws" {
  region = "us-east-1"
}


###
# DynamoDB
####

module "dynamodb" {
  source = "../../modules/aws-dynamodb"
  dynamoTable_Name = "cloudgeeks.ca-vault"
  read_capacity    = 5
  write_capacity   = 5
  tag_Name         = "cloudgeeks.ca-vault"
  tag_Environment  = "dev"
}

#####
# Vpc
#####

module "vpc" {
  source = "../../modules/aws-vpc"

  vpc-location                        = "Virginia"
  namespace                           = "cloudgeeks.ca"
  name                                = "vpc"
  stage                               = "vault-dev"
  map_public_ip_on_launch             = "true"
  total-nat-gateway-required          = "1"
  create_database_subnet_group        = "true"
  vpc-cidr                            = "10.20.0.0/16"
  vpc-public-subnet-cidr              = ["10.20.1.0/24","10.20.2.0/24"]
  vpc-private-subnet-cidr             = ["10.20.4.0/24","10.20.5.0/24"]
  vpc-database_subnets-cidr           = ["10.20.7.0/24", "10.20.8.0/24"]
}


module "sg1" {
  source              = "../../modules/aws-sg-cidr"
  namespace           = "cloudgeeks.ca"
  stage               = "dev"
  name                = "vault"
  tcp_ports           = "22,80,443,8201,23525"
  cidrs               = ["111.119.187.1/32"]
  security_group_name = "vault"
  vpc_id              = module.vpc.vpc-id
}

module "sg2" {
  source                  = "../../modules/aws-sg-ref-v2"
  namespace               = "cloudgeeks.ca"
  stage                   = "dev"
  name                    = "vault-Ref"
  tcp_ports               = "22,80,443,8201,3306"
  ref_security_groups_ids = [module.sg1.aws_security_group_default,module.sg1.aws_security_group_default,module.sg1.aws_security_group_default,module.sg1.aws_security_group_default,module.sg1.aws_security_group_default,module.sg1.aws_security_group_default]
  security_group_name     = "vault-Ref"
  vpc_id                  = module.vpc.vpc-id
}


module "openvpn-eip" {
  source = "../../modules/aws-eip/openvpn"
  name                         = "vault"
  instance                     = module.ec2-openvpn.id[0]
}

module "ec2-openvpn" {
  source                        = "../../modules/aws-ec2"
  namespace                     = "cloudgeeks.ca"
  stage                         = "dev"
  name                          = "openvpn"
  key_name                      = "vault-demo"
  public_key                    = file("../../modules/secrets/vault-demo.pub")
  user_data                     = file("../../modules/aws-ec2/user-data/user-data.sh")
  instance_count                = 1
  ami                           = "ami-0fc61db8544a617ed"
  instance_type                 = "t3a.medium"
  associate_public_ip_address   = "true"
  root_volume_size              = 10
  subnet_ids                    = module.vpc.public-subnet-ids
  vpc_security_group_ids        = [module.sg1.aws_security_group_default]

}

module "ec2-vault-master" {
  source                        = "../../modules/aws-ec2"
  namespace                     = "cloudgeeks.ca"
  stage                         = "dev"
  name                          = "vault-master"
  key_name                      = "vault-master"
  public_key                    = file("../../modules/secrets/vault-master.pub")
  instance_count                = 1
  ami                           = "ami-085925f297f89fce1"
  instance_type                 = "t3a.medium"
  associate_public_ip_address   = "false"
  root_volume_size              = 10
  subnet_ids                    = module.vpc.private-subnet-ids
  vpc_security_group_ids        = [module.sg2.aws_security_group_default]

}

module "ec2-vault-failover" {
  source                        = "../../modules/aws-ec2"
  namespace                     = "cloudgeeks.ca"
  stage                         = "dev"
  name                          = "vault-failover"
  key_name                      = "vault-failover"
  public_key                    = file("../../modules/secrets/vault-failover.pub")
  instance_count                = 1
  ami                           = "ami-085925f297f89fce1"
  instance_type                 = "t3a.medium"
  associate_public_ip_address   = "false"
  root_volume_size              = 10
  subnet_ids                    = module.vpc.private-subnet-ids
  vpc_security_group_ids        = [module.sg2.aws_security_group_default]

}


module "rds-mysql" {
  source                                                           = "../../modules/aws-rds-mysql"
  namespace                                                        = "cloudgeeks.ca"
  stage                                                            = "dev"
  name                                                             = "wordpress-db"
  rds-name                                                         = "wordpress-db"
  final-snapshot-identifier                                        = "cloudgeeks.ca-db-final-snap-shot"
  skip-final-snapshot                                              = "true"
  rds-allocated-storage                                            = "5"
  storage-type                                                     = "gp2"
  rds-engine                                                       = "mysql"
  engine-version                                                   = "5.7.17"
  db-instance-class                                                = "db.t2.micro"
  backup-retension-period                                          = "0"
  backup-window                                                    = "04:00-06:00"
  publicly-accessible                                              = "false"
  rds-username                                                     = "devops"
  rds-password                                                     = "987654321"
  multi-az                                                         = "true"
  storage-encrypted                                                = "false"
  deletion-protection                                              = "false"
  vpc-security-group-ids                                           = [module.sg2.aws_security_group_default]
  subnet_ids                                                       = module.vpc.database_subnets
}