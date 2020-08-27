#########
# Labels
#########
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

resource "aws_secretsmanager_secret" "this" {
  name        = var.name
  description = "This secret is created by terrraform for ${module.label.id}"
  tags        = module.label.tags
  kms_key_id  = var.kms_key_id
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id      = aws_secretsmanager_secret.this.id
  secret_string  = jsonencode(var.secret-string)
  version_stages = var.version_stages

}
