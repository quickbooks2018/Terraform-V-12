resource "aws_iam_instance_profile" "instance_profile" {
  name = var.instance_profile
  role = var.iam_role
}