###
# vpv-home
###

module "vpc-home" {
  source = "../../modules/aws-vpc"

  vpc-location                        = "Virginia"
  namespace                           = "cloudelligent-home"
  name                                = "vpc"
  stage                               = "dev"
  map_public_ip_on_launch             = "true"
  total-nat-gateway-required          = "1"
  create_database_subnet_group        = "false"
  vpc-cidr                            = "30.31.0.0/16"
  vpc-public-subnet-cidr              = ["30.31.1.0/24","30.31.2.0/24"]
  vpc-private-subnet-cidr             = ["30.31.4.0/24","30.31.5.0/24"]
  vpc-database_subnets-cidr           = ["30.31.7.0/24", "30.31.8.0/24"]
  tgw-route-cidr                      = "30.30.0.0/16"
  transit_gateway_id                  = module.transit-gateway.EC2_Transit_Gateway_identifier_ID
}


# VPC-2-SG


module "sg-tgw-vpc-home" {
  source = "../../modules/aws-sg-tgw"
  security_group_name        = "TGW-sg-vpc-home"
  vpc_id                     =  module.vpc-home.vpc-id

  # Rule-1
  ingress-rule-1-from-port = 22
  ingress-rule-1-to-port = 22
  ingress-rule-1-protocol = "tcp"
  ingress-rule-1-cidrs = ["10.11.1.160/32"]
  ingress-rule-1-description = "Muhammad Asim Premises"


  # Rule-3
  ingress-rule-3-from-port   = -1
  ingress-rule-3-to-port     = -1
  ingress-rule-3-protocol    = "icmp"
  ingress-rule-3-cidrs       = ["0.0.0.0/0"]
  ingress-rule-3-description = "Ingress Rule"

}




# EC2-Private---> Launched in VPC-HOME

module "ec2-transit-gateway-private" {
  source                        = "../../modules/aws-ec2"
  namespace                     = "cloudelligent"
  stage                         = "dev"
  name                          = "transit-gateway"
  key_name                      = "transit-gateway-home-vpc"
  public_key                    = file("../../modules/secrets/transit-gateway-home-vpc.pub")
  instance_count                = 1
  ami                           = "ami-06fcc1f0bc2c8943f"
  instance_type                 = "t3a.medium"
  associate_public_ip_address   = "false"
  root_volume_size              = 8
  subnet_ids                    = module.vpc-home.private-subnet-ids
  vpc_security_group_ids        = [module.sg-tgw-vpc-home.aws_security_group]

}


### Transit gateway Additional Vpc attachments

module "transit-gateway-vpc-home-attachment" {
  source                             = "../../modules/aws-trasit-gateway-addtional-attachments"

  transit_gateway_id                                                     = module.transit-gateway.EC2_Transit_Gateway_identifier_ID
  subnet_ids                                                             = module.vpc-home.private-subnet-ids
  # aws_ec2_transit_gateway_vpc_attachment
  vpc_id                                                                 =  module.vpc-home.vpc-id
  aws_ec2_transit_gateway_vpc_attachment_name                            = "cloudelligent-tgw-vpc-home-attahments"
  transit_gateway_default_route_table_association                        = "true"
  transit_gateway_default_route_table_propagation                        = "true"
}
