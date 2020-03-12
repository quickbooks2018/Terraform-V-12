#Creating EC2-Key Pair
provider "aws" {
  region = var.region
}

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

resource "aws_key_pair" "keypair" {
  key_name   = var.key-name
  public_key = var.public-key
}
