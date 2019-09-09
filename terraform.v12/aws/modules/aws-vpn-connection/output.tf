output "vpn-connection" {
  value = aws_vpn_connection.vpn.id
}
output "vpn-connection-route" {
  value = aws_vpn_connection_route.office.id
}