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
  create_database_subnet_group        = "true"
  vpc-cidr                            = "10.11.0.0/16"
  vpc-public-subnet-cidr              = ["10.11.1.0/24","10.11.2.0/24"]
  vpc-private-subnet-cidr             = ["10.11.4.0/24","10.11.5.0/24"]
  vpc-database_subnets-cidr           = ["10.11.7.0/24", "10.11.8.0/24"]
}

### RDS ##
module "rds-mysql" {
  source                                                           = "../../modules/aws-rds-mysql"
  namespace                                                        = "cloudgeeks.ca"
  stage                                                            = "dev"
  name                                                             = "wordpress-db"
  rds-name                                                         = "wordpress-db"
  final-snapshot-identifier                                        = "cloudgeeks-ca-db-final-snap-shot"
  skip-final-snapshot                                              = "true"
  rds-allocated-storage                                            = "5"
  storage-type                                                     = "gp2"
  rds-engine                                                       = "mysql"
  engine-version                                                   = "5.7.17"
  db-instance-class                                                = "db.t2.micro"
  backup-retension-period                                          = "0"
  backup-window                                                    = "04:00-06:00"
  publicly-accessible                                              = "false"
  rds-username                                                     = "demo"
  rds-password                                                     = var.rds-secret
  multi-az                                                         = "true"
  storage-encrypted                                                = "false"
  deletion-protection                                              = "false"
  vpc-security-group-ids                                           = [module.sg2.aws_security_group_default]
  subnet_ids                                                       = module.vpc.database_subnets
}

module "kms_rds-mysql_key" {
  source                  = "../../modules/aws-kms"
  namespace               = "cloudgeeks.ca"
  stage                   = "dev"
  name                    = "rds-mysql-key"
  alias                   = "alias/asim"
  deletion_window_in_days = "10"
}


module "rds_secret" {
  source               = "../../modules/aws-secret-manager"
  namespace            = "cloudgeeks.ca"
  stage                = "dev"
  name                 = "mysql_password"
  secret-string         = {
    username             = "demo"
    password             = var.secret-manager
    engine               = "mysql"
    host                 = module.rds-mysql.rds-end-point
    port                 = "3306"
    dbInstanceIdentifier = "wordpress-db"
  }
  kms_key_id             = module.kms_rds-mysql_key.key_id
}




### Security Groups ###
module "sg1" {
  source              = "../../modules/aws-sg-cidr"
  namespace           = "cloudgeeks.ca"
  stage               = "dev"
  name                = "WebServer"
  tcp_ports           = "80,443"
  cidrs               = ["0.0.0.0/0"]
  security_group_name = "Web"
  vpc_id              = module.vpc.vpc-id
}

module "sg2" {
  source                      = "../../modules/aws-sg-ref"
  namespace                   = "cloudgeeks.ca"
  stage                       = "dev"
  name                        = "Web-Ref"
  tcp_ports                   = "22,3306"
  ref_security_groups_ids     =  module.sg1.aws_security_group_default
  security_group_name         = "Web-Ref"
  vpc_id                      = module.vpc.vpc-id
}



module "sg3" {
  source              = "../../modules/aws-sg-cidr"
  namespace           = "cloudgeeks.ca"
  stage               = "dev"
  name                = "PriTunl"
  udp_ports           = "12323"
  tcp_ports           = "80,443"
  cidrs               = ["0.0.0.0/0"]
  security_group_name = "Pritunl"
  vpc_id              = module.vpc.vpc-id
}

module "sg4" {
  source                  = "../../modules/aws-sg-ref-v2"
  namespace               = "cloudgeeks.ca"
  stage                   = "dev"
  name                    = "PriTunl-Ref"
  tcp_ports               = "22,80,443"
  ref_security_groups_ids = [module.sg3.aws_security_group_default,module.sg3.aws_security_group_default,module.sg3.aws_security_group_default]
  security_group_name     = "Pritunl-Ref"
  vpc_id                  = module.vpc.vpc-id
}


module "sg5" {
  source = "../../modules/aws-sg-cidr-v2"
  namespace                     = "cloudgeeks.ca"
  stage                         = "dev"
  name                          = "ec2"
  security_group_name           = "ec2"
  vpcID                         = module.vpc.vpc-id
  ServicePorts                  = {
    http                        = 80
    https                       = 443
  }

  cidr                          = "0.0.0.0/0"

}

module "sg6" {
  source                  = "../../modules/aws-sg-ref"
  namespace               = "cloudgeeks.ca"
  stage                   = "dev"
  name                    = "Testing-Ref"
  tcp_ports               = "22,433"
  ref_security_groups_ids = module.sg3.aws_security_group_default
  security_group_name     = "Testing-Ref"
  vpc_id                  = module.vpc.vpc-id
}

