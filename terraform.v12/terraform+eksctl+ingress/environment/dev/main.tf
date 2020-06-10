provider "aws" {
  region = "us-east-1"
}


module "vpc" {
  source = "../../modules/vpc"
  vpc-location                        = "Virginia"
  namespace                           = "cloudgeeks.ca"
  name                                = "vpc"
  stage                               = "dev"
  map_public_ip_on_launch             = "false"
  total-nat-gateway-required          = "1"
  create_database_subnet_group        = "false"
  vpc-cidr                            = "10.11.0.0/16"
  vpc-public-subnet-cidr              = ["10.11.16.0/20","10.11.32.0/20"]
  vpc-private-subnet-cidr             = ["10.11.48.0/20","10.11.64.0/20"]
  vpc-database_subnets-cidr           = ["10.11.80.0/20", "10.11.96.0/20"]
  cluster-name                        = "cloudgeeks-ca-eks"

}
