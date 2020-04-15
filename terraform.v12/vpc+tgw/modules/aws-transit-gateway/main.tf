resource "aws_ec2_transit_gateway" "aws_ec2_transit_gateway" {

  auto_accept_shared_attachments   = var.auto_accept_shared_attachments


  # Private Autonomous System Number (ASN) for the Amazon side of a BGP session. The range is 64512 to 65534 for 16-bit ASNs and 4200000000 to 4294967294 for 32-bit ASNs. Default value: 64512
  amazon_side_asn                  = var.amazon_side_asn

  # VPN Equal Cost Multipath Protocol
  vpn_ecmp_support                 = var.vpn_ecmp_support

  default_route_table_association  = var.default_route_table_association

  default_route_table_propagation =  var.default_route_table_propagation

  dns_support                      = var.dns_support

  tags                             =  {

    Name                           = var.transit_gateway_name
  }

}



# aws_ec2_transit_gateway_vpc_attachment

resource "aws_ec2_transit_gateway_vpc_attachment" "aws_ec2_transit_gateway_vpc_attachment" {
  subnet_ids = var.subnet_ids
  transit_gateway_id = var.transit_gateway_id
  vpc_id = var.vpc_id
  tags = {
    Name = var.aws_ec2_transit_gateway_vpc_attachment_name
  }
  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation

}