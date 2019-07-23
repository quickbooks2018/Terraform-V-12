module "vpc" {
  source = "./modules/vpc"

  ###VPC###
  instance-tenancy              = "default"
  enable-dns-support            = "true"
  enable-dns-hostnames          = "true"
  vpc-name                      = "Cloudelligent-vpc"
  vpc-location                  = "Frankfurt"
  region                        = "eu-central-1"
  internet-gateway-name         = "Cloudelligent-igw"
  map_public_ip_on_launch       = "true"
  public-subnets-name           = "public-subnets"
  public-subnets-location       = "Frankfurt"
  public-subnet-routes-name     = "public-subnet-routes"
  private-subnets-location-name = "Frankfurt"
  private-subnet-name           = "private-subnets"
  total-nat-gateway-required    = "1"
  eip-for-nat-gateway-name      = "eip-nat-gateway"
  nat-gateway-name              = "nat-gateway"
  private-route-cidr            = "0.0.0.0/0"
  private-route-name            = "private-route"
  vpc-cidr                      = "10.11.0.0/16"
  vpc-public-subnet-cidr        = ["10.11.1.0/24", "10.11.2.0/24", "10.11.3.0/24"]
  vpc-private-subnet-cidr       = ["10.11.4.0/24", "10.11.5.0/24", "10.11.6.0/24"]
}

