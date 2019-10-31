output "id" {
  value = aws_emr_cluster.cluster.id
}

output "name" {
  value = aws_emr_cluster.cluster.name
}

output "master_public_dns" {
  value = aws_emr_cluster.cluster.master_public_dns
}
