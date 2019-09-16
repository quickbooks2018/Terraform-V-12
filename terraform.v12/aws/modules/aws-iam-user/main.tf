#IAM USER CREATION

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

resource "aws_iam_access_key" "this" {
  user    = aws_iam_user.this.name
}

resource "aws_iam_user" "this" {
  name = var.user-name
  path = "/system/"
  tags = module.label.tags
}

resource "aws_iam_user_policy" "this" {
  name = var.policy-name
  user = aws_iam_user.this.name
  policy = var.iam-user-policy
}