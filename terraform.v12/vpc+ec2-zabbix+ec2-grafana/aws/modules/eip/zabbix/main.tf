resource "aws_eip" "default" {
  vpc                       = var.vpc
  instance                  = var.instance
  network_interface         = var.network_interface
  associate_with_private_ip = var.associate_with_private_ip
  public_ipv4_pool          = var.public_ipv4_pool

  tags = merge(var.tags, { "Name" = var.name })
}