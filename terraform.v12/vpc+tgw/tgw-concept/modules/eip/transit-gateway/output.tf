output "id" {
  description = "Contains the EIP allocation ID"
  value       = aws_eip.default.id
}

output "public_ip" {
  description = "Contains the public IP address"
  value       = aws_eip.default.public_ip
}

output "public_dns" {
  description = "Public DNS associated with the Elastic IP address"
  value       = aws_eip.default.public_dns
}
