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

###
# AWS Cloud_Watch Log Group
###

resource "aws_cloudwatch_log_group" "awsclientvpn_log_group" {
  name = "aws_client_vpn"

  tags = {
    Environment = "dev"
    Application = "awsclientvpn"
  }
}

resource "aws_cloudwatch_log_stream" "awsclientvpn_log_stream" {
  name           = "aws_client_vpn"
  log_group_name = aws_cloudwatch_log_group.awsclientvpn_log_group.name
}


###
# AWS Simple_AD
###

module "aws_simple_ad" {
  source = "../../modules/aws_simple_AD"

  # aws_directory_service_directory

  name                    = "corp.saqlainmushtaq.com"
  password                = "Saqlainmushtaq-com-pk"
  size                    = "Small"

  # vpc_settings

  vpc_id                  = module.vpc.vpc-id
  subnet_ids              = module.vpc.private-subnet-ids
  tag                     = "aws-simple-ad"

}


###
# AWS Client VPN
###

module "client_vpn" {
  source = "../../modules/aws-client-vpn"

  # # aws_ec2_client_vpn_endpoint

  Client_Vpn_Name                         = "AWS Client VPN"
  description                             = "aws clinet vpn"
  server_certificate_arn                  = "arn:aws:acm:us-east-1:504649076991:certificate/cf5d726e-f11e-44f3-a099-5ebc47c911a0"
  client_cidr_block                       = "10.2.0.0/16"
  split_tunnel                            = true

  # authentication_options

  # Choose ---> certificate-authentication for Certs or for AD choose ----> directory-service-authentication

  type                                    = "directory-service-authentication"
  root_certificate_chain_arn              = "arn:aws:acm:us-east-1:504649076991:certificate/cf5d726e-f11e-44f3-a099-5ebc47c911a0"
  active_directory_id                     = module.aws_simple_ad.aws_simple_ad_id


  # connection_log_options

  enabled                                 = true
  cloudwatch_log_group_name               = "aws_client_vpn"
  cloudwatch_log_stream_name              = "aws_client_vpn"

}


