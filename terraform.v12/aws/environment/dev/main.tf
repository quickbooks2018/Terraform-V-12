provider "aws" {
  region = "eu-central-1"
}

#####
# Vpc
#####

module "vpc" {
  source = "../../modules/aws-vpc"

  vpc-location                        = "Frankfurt"
  namespace                           = "cloudelligent"
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


module "vgw" {
  source = "../../modules/aws-vgw"
  namespace                   = "cloudelligent"
  stage                       = "dev"
  name                        = "vgw"
  vpc-id                      = module.vpc.vpc-id
  vgw-public-route-table-id   = module.vpc.aws-route-table-public-routes-id
  vgw-private-route-table-id  = module.vpc.aws-route-table-private-routes-id
}

module "cgw" {
  source = "../../modules/aws-cgw"
  namespace                         = "cloudelligent"
  stage                             = "dev"
  name                              = "cgw"
  customer-gateway-static-public-ip = "119.153.177.80"
}

module "vpn-connection" {
  source = "../../modules/aws-vpn-connection"
  namespace                       = "cloudelligent"
  stage                           = "dev"
  name                            = "vpn-connection"
  customer-gateway-id             = module.cgw.customer-gateway
  vpn-gateway-id                  = module.vgw.vgw
  vpc-id                          = module.vpc.vpc-id
  office-private-cidr             = "192.168.0.0/16"
}

module "kms_s3_key" {
  source                  = "../../modules/aws-kms"
  namespace               = "cloudelligent"
  stage                   = "dev"
  name                    = "s3-key"
  deletion_window_in_days = "10"
}

module "sg1" {
  source              = "../../modules/aws-sg-cidr"
  namespace           = "cloudelligent"
  stage               = "dev"
  name                = "WebServer"
  tcp_ports           = "80,443"
  cidrs               = ["0.0.0.0/0"]
  security_group_name = "Web"
  vpc_id              = module.vpc.vpc-id
}

module "sg2" {
  source                      = "../../modules/aws-sg-ref"
  namespace                   = "cloudelligent"
  stage                       = "dev"
  name                        = "Web-Ref"
  tcp_ports                   = "22,3306"
  ref_security_groups_ids     =  module.sg1.aws_security_group_default
  security_group_name         = "Web-Ref"
  vpc_id                      = module.vpc.vpc-id
}



module "sg3" {
  source              = "../../modules/aws-sg-cidr"
  namespace           = "cloudelligent"
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
  namespace               = "cloudelligent"
  stage                   = "dev"
  name                    = "PriTunl-Ref"
  tcp_ports               = "22,80,443"
  ref_security_groups_ids = [module.sg3.aws_security_group_default,module.sg3.aws_security_group_default,module.sg3.aws_security_group_default]
  security_group_name     = "Pritunl-Ref"
  vpc_id                  = module.vpc.vpc-id
}


module "sg5" {
  source = "../../modules/aws-sg-cidr-v2"
  namespace                     = "cloudelligent"
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
  namespace               = "cloudelligent"
  stage                   = "dev"
  name                    = "Testing-Ref"
  tcp_ports               = "22,433"
  ref_security_groups_ids = module.sg3.aws_security_group_default
  security_group_name     = "Testing-Ref"
  vpc_id                  = module.vpc.vpc-id
}


module "ec2" {
  source                        = "../../modules/aws-ec2"
  namespace                     = "cloudelligent"
  stage                         = "dev"
  name                          = "ec2"
  key_name                      = "ec2-v12"
  public_key                    = file("../../modules/secrets/ec2-v12.pub")
  instance_count                = 1
  ami                           = "ami-00aa4671cbf840d82"
  instance_type                 = "t3a.micro"
  associate_public_ip_address   = "true"
  subnet_ids                    = module.vpc.public-subnet-ids
  vpc_security_group_ids        = [module.sg2.aws_security_group_default,module.sg1.aws_security_group_default]
  iam_instance_profile          = module.instance-profile.instance-profile-name
}

module "instance-profile" {
  source = "../../modules/aws-instance-profile"
  instance_profile = "ec2"
  iam_role         = module.iam-role-ec2-secret-manager.iam_role_name
}

module "ec2-pritunl" {
  source                        = "../../modules/aws-ec2"
  namespace                     = "cloudelligent"
  stage                         = "dev"
  name                          = "ec2"
  key_name                      = "ec2-v12"
  public_key                    = file("../../modules/secrets/ec2-v12.pub")
  user_data                     = file("../../modules/aws-ec2/user-data/user-data.sh")
  instance_count                = 1
  ami                           = "ami-010fae13a16763bb4"
  instance_type                 = "t3a.micro"
  associate_public_ip_address   = "true"
  subnet_ids                    = module.vpc.public-subnet-ids
  vpc_security_group_ids        = [module.sg3.aws_security_group_default,module.sg4.aws_security_group_default]
}

module "rds-mysql" {
  source                                                           = "../../modules/aws-rds-mysql"
  namespace                                                        = "cloudelligent"
  stage                                                            = "dev"
  name                                                             = "wordpress-db"
  rds-name                                                         = "wordpress-db"
  final-snapshot-identifier                                        = "cloudeligent-db-final-snap-shot"
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
  rds-password                                                     = "fakepassword"
  multi-az                                                         = "true"
  storage-encrypted                                                = "false"
  deletion-protection                                              = "false"
  vpc-security-group-ids                                           = [module.sg2.aws_security_group_default]
  subnet_ids                                                       = module.vpc.database_subnets
}

module "key-pair" {
  source = "../../modules/aws-ec2-keypair"
  namespace                       = "cloudelligent"
  stage                           = "dev"
  name                            = "ec2-keypair"
  region                          = "eu-central-1"
  key-name                        = "cloudelligent-dev-admin"
  public-key                      = file("../../modules/secrets/ec2-v12.pub")
}

module "iam-role-ec2-secret-manager" {
  source = "../../modules/aws-iam-role"
  namespace                       = "cloudelligent"
  stage                           = "dev"
  name                            = "ec2-assume-role"
  iam-role-name                   = "ec2-secret-manager-role"
  policy-name                     = "Secret-Manager"
  policy                          = file("../../modules/aws-policies/ec2-secret-manager-policy.json")
}

module "iam-user-1" {
  source = "../../modules/aws-iam-user"
  namespace                       = "cloudelligent"
  stage                           = "dev"
  name                            = "asim-arain"
  user-name                       = "asim-arain"
  policy-name                     = "cloudelligent-dev-bucket-policy"
  iam-user-policy                 = file("../../modules/aws-policies/iam-user-s3-policy.json")
}


module "kms_rds-mysql_key" {
  source                  = "../../modules/aws-kms"
  namespace               = "cloudelligent"
  stage                   = "dev"
  name                    = "rds-mysql-key"
  deletion_window_in_days = "10"
}


module "rds_secret" {
  source               = "../../modules/aws-secret-manager"
  namespace            = "cloudelligent"
  stage                = "dev"
  name                 = "Mysql_Password"
  secret-string         = {
    username             = "demo"
    password             = "fakepassword"
    engine               = "mysql"
    host                 = "wordpress-db.ci6ifuaz6osi.eu-central-1.rds.amazonaws.com"
    port                 = "3306"
    dbInstanceIdentifier = "wordpress-db"
  }
  kms_key_id             = ""
}


module "ec2-postgresql-master" {
  source                        = "../../modules/aws-ec2"
  namespace                     = "cloudelligent"
  stage                         = "dev"
  name                          = "ec2-postgresql-master"
  key_name                      = "ec2-v12"
  public_key                    = file("../../modules/secrets/ec2-v12.pub")
  instance_count                = 1
  ami                           = "ami-00aa4671cbf840d82"
  instance_type                 = "t3a.micro"
  associate_public_ip_address   = "true"
  subnet_ids                    = module.vpc.public-subnet-ids
  vpc_security_group_ids        = [module.sg2.aws_security_group_default,module.sg1.aws_security_group_default]
  ebs_block_device              = [
    {
      device_name = "/dev/sdb"
      volume_type = "gp2"
      volume_size = 5
      delete_on_termination = "false"

    }
  ]

   root_block_device = [
   {
       volume_type = "gp2"
        volume_size = 10
    }
]


}



module "ec2-postgresql-slave1" {
  source                        = "../../modules/aws-ec2"
  namespace                     = "cloudelligent"
  stage                         = "dev"
  name                          = "ec2-postgresql-slave1"
  key_name                      = "ec2-v12"
  public_key                    = file("../../modules/secrets/ec2-v12.pub")
  instance_count                = 1
  ami                           = "ami-00aa4671cbf840d82"
  instance_type                 = "t3a.micro"
  associate_public_ip_address   = "true"
  subnet_ids                    = module.vpc.public-subnet-ids
  vpc_security_group_ids        = [module.sg2.aws_security_group_default,module.sg1.aws_security_group_default]
  ebs_block_device              = [
    {
      device_name = "/dev/sdb"
      volume_type = "gp2"
      volume_size = 5
      delete_on_termination = "false"

    }
  ]

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
    }
  ]

}

module "ec2-postgresql-slave2" {
  source                        = "../../modules/aws-ec2"
  namespace                     = "cloudelligent"
  stage                         = "dev"
  name                          = "ec2-postgresql-slave2"
  key_name                      = "ec2-v12"
  public_key                    = file("../../modules/secrets/ec2-v12.pub")
  instance_count                = 1
  ami                           = "ami-00aa4671cbf840d82"
  instance_type                 = "t3a.micro"
  associate_public_ip_address   = "true"
  subnet_ids                    = module.vpc.public-subnet-ids
  vpc_security_group_ids        = [module.sg2.aws_security_group_default,module.sg1.aws_security_group_default]
  ebs_block_device              = [
    {
      device_name = "/dev/sdb"
      volume_type = "gp2"
      volume_size = 5
      delete_on_termination = "false"

    }
  ]

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
    }
  ]

}