resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
  description            = var.description
  server_certificate_arn = var.server_certificate_arn
  client_cidr_block      = var.client_cidr_block
  split_tunnel           = var.split_tunnel
  depends_on             = [var.cloudwatch_log_stream_name]
  tags                   = {

    Name                 = var.Client_Vpn_Name

  }

  authentication_options {
    type                       = var.type
    root_certificate_chain_arn = var.root_certificate_chain_arn
    active_directory_id        =  var.active_directory_id
  }

  connection_log_options {
    enabled               = var.enabled
    cloudwatch_log_group  = var.cloudwatch_log_group_name
    cloudwatch_log_stream = var.cloudwatch_log_stream_name
  }
}

