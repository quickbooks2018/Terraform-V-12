#########
# Labels
########
module "label" {
  source     = "../terraform-label"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
  enabled    = var.enabled
}


resource "aws_vpn_connection" "vpn" {
  vpn_gateway_id      = var.vpn-gateway-id
  customer_gateway_id = var.customer-gateway-id
  type                = "ipsec.1"
  static_routes_only  = true
  tags = module.label.tags
}

resource "aws_vpn_connection_route" "office" {
  destination_cidr_block = var.office-private-cidr
  vpn_connection_id      = aws_vpn_connection.vpn.id
}