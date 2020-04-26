resource "aws_directory_service_directory" "simple_ad" {
  name     = var.name
  password = var.password
  size     = var.size

  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = var.subnet_ids
  }

  tags = {
    Name = var.tag
  }
}