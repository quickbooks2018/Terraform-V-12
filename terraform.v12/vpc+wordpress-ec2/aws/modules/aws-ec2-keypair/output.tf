#OUTPUT EC2 KEYPAIR
output "key-pair" {
  value = aws_key_pair.keypair.id
}

output "key-name" {
  value = aws_key_pair.keypair.key_name
}

output "public-key" {
  value = aws_key_pair.keypair.public_key
}