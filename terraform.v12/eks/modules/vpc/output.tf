# Output of VPC

output "vpc-id" {
  description = "The ID of the VPC"
  value       = concat(aws_vpc.vpc.*.id, [""])[0]
}


# Output of IGW

output "igw" {
  value = aws_internet_gateway.igw.*.id
}

# Output of Public Subnet

output "public-subnet-ids" {
  description = "Public Subnets IDS"
  value       = aws_subnet.public-subnets.*.id
}

# Output of EIP For NAT Gateways

output "eip-ngw" {
  value = aws_eip.eip-ngw.*.id
}

# Output Of NAT-Gateways

output "ngw" {
  value = aws_nat_gateway.ngw.*.id
}

# Output Of Private Subnet

output "private-subnet-ids" {
  description = "Private Subnets IDS"
  value       = aws_subnet.private-subnets.*.id
}

# Output Of Public Subnet Associations With Public Route Tables

output "public-association" {
  value = aws_route_table_association.public-association.*.id
}

# Output Of Public Routes

output "aws-route-table-public-routes-id" {
  value = aws_route_table.public-routes.*.id
}

# Output Of Region AZS

output "aws-availability-zones" {
  value = data.aws_availability_zones.azs.names
}

# Output Of Private Route Table ID's

output "aws-route-table-private-routes-id" {
  value = aws_route_table.private-routes.*.id
}


# Database Subnets

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = aws_subnet.database.*.id
}

output "database_subnet_arns" {
  description = "List of ARNs of database subnets"
  value       = aws_subnet.database.*.arn
}

output "database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = aws_subnet.database.*.cidr_block
}

output "database_subnet_group" {
  description = "ID of database subnet group"
  value       = concat(aws_db_subnet_group.database.*.id, [""])[0]
}
