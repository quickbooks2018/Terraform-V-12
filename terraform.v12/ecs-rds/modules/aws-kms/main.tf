resource "aws_kms_key" "kms" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
}

resource "aws_kms_alias" "kms_alias" {
  name = var.kms_alias
  target_key_id = aws_kms_key.kms.id
}