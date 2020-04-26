# aws_clinet_vpn_endpoint

output "aws_clinet_vpn_endpoint" {
  value = aws_ec2_client_vpn_endpoint.client_vpn.dns_name
}