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
}

########
# KMS
########
resource "aws_kms_key" "default" {
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  tags                    = module.label.tags
  description             = var.description
}

resource "aws_kms_alias" "default" {
  name          = coalesce(var.alias, format("alias/%v", module.label.id))
  target_key_id = aws_kms_key.default.id
}
