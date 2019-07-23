#VPC
variable "instance-tenancy" {
  default = ""
}
variable "enable-dns-support" {
  default = ""
}

variable "enable-dns-hostnames" {
  default = ""
}
##############################
#VPC TAGS
#-----------
#VPC NAME
variable "vpc-name" {
  default = ""
}
#VPC LOCATION
variable "vpc-location" {
  default = ""
}
############################
#VPC Region
variable "region" {
  default = ""
}
############################
#INTERNET-GATEWAY TAGS
variable "internet-gateway-name" {
  default = ""
}

##############################
#PUBLIC-SUBNET TAGS
variable "map_public_ip_on_launch" {
  default = ""
}
variable "public-subnets-name" {
  default = ""
}
variable "public-subnets-location" {
  default = ""
}
variable "public-subnet-routes-name" {
  default = ""
}

#######################################
#PRIVATE-SUBNETS TAGS
variable "private-subnets-location-name" {
  default = ""
}
######################################
#NAT-GATEWAYS REQUIRED
variable "total-nat-gateway-required" {
  default = ""
}

#EIP TAGS
variable "eip-for-nat-gateway-name" {
  default = ""
}

#NAT-GATEWAY TAGS
variable "nat-gateway-name" {
  default = ""
}


#PRIVATE ROUTES CIDR
variable "private-route-cidr" {
  default = ""
}

#PRIVATE ROUTE TAGS
variable "private-route-name" {
  default = ""
}
###########################################################################
#VPC CIDR BLOCK
variable "vpc-cidr" {
  default = ""
}

#VPC PUBLIC SUBNETS CIDR BLOCK LIST
variable "vpc-public-subnet-cidr" {
  type = "list"
}

#VPC PRIVATE SUBNETS CIDR BLOCK LIST
variable "vpc-private-subnet-cidr" {
  type = "list"
}

#PRIVATE SUBNETS TAGS
variable "private-subnet-name" {
  default = ""
}

#FETCH AZS FROM REGION
data "aws_availability_zones" "azs" {}
