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


resource "aws_customer_gateway" "customer-gateway" {
  bgp_asn = 65000
  ip_address = var.customer-gateway-static-public-ip
  type = "ipsec.1"
  tags = module.label.tags
}
