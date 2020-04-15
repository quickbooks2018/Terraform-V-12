provider "aws" {
  region = "us-east-1"
}

#####
# Vpc
#####

module "vpc" {
  source = "../../modules/aws-vpc"

  vpc-location                        = "Virginia"
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
  tgw-route-cidr                     =  "192.168.0.0/16"
  transit_gateway_id                  = module.transit-gateway.EC2_Transit_Gateway_identifier_ID
}

# VPC-1-SG


module "sg-tgw" {
  source = "../../modules/aws-sg-tgw"
  security_group_name = "TGW-sg"
  vpc_id = module.vpc.vpc-id

  # Rule-1
  ingress-rule-1-from-port = 22
  ingress-rule-1-to-port = 22
  ingress-rule-1-protocol = "tcp"
  ingress-rule-1-cidrs = ["119.153.141.87/32"]
  ingress-rule-1-description = "Muhammad Asim Premises"


  # Rule-3
  ingress-rule-3-from-port   = -1
  ingress-rule-3-to-port     = -1
  ingress-rule-3-protocol    = "icmp"
  ingress-rule-3-cidrs       = ["0.0.0.0/0"]
  ingress-rule-3-description = "Ingress Rule"

}




# EC2-Public
module "ec2-transit-gateway-public" {
  source                        = "../../modules/aws-ec2"
  namespace                     = "cloudelligent"
  stage                         = "dev"
  name                          = "transit-gateway"
  key_name                      = "transit-gateway"
  public_key                    = file("../../modules/secrets/transit-gateway.pub")
  instance_count                = 1
  ami                           = "ami-0fc61db8544a617ed"
  instance_type                 = "t3a.medium"
  associate_public_ip_address   = "true"
  root_volume_size              = 8
  subnet_ids                    = module.vpc.public-subnet-ids
  vpc_security_group_ids        = [module.sg-tgw.aws_security_group]

}


### AWS Transit Gateway

module "transit-gateway" {
  source                             = "../../modules/aws-transit-gateway"

  transit_gateway_name                                                   = "cloudelligent-transit-gateway"
  auto_accept_shared_attachments                                         = "enable"
  amazon_side_asn                                                        = "64512"
  vpn_ecmp_support                                                       = "enable"
  default_route_table_association                                        = "enable"
  default_route_table_propagation                                        = "enable"
  dns_support                                                            = "enable"
  transit_gateway_id                                                     = module.transit-gateway.EC2_Transit_Gateway_identifier_ID
  subnet_ids                                                             = module.vpc.private-subnet-ids
  # aws_ec2_transit_gateway_vpc_attachment
  vpc_id                                                                 =  module.vpc.vpc-id
  aws_ec2_transit_gateway_vpc_attachment_name                            = "cloudelligent-tgw-vpc-dev-attahments"
  transit_gateway_default_route_table_association                        = "true"
  transit_gateway_default_route_table_propagation                        = "true"
}



