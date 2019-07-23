#OUTPUT OF VPC-ID
output "vpc-id" {
  description = "The ID of the VPC"
  value = "${aws_vpc.vpc.id}"
}

#OUTPUT OF IGW
output "igw" {
  value = "${aws_internet_gateway.igw.id}"
}

#OUTPUT OF PUBLIC SUBNET IDS
output "public-subnet-ids" {
  description = "Public Subnets IDS"
  value = "${aws_subnet.public-subnets.*.id}"
}

#OUTPUT OF EIP FOR NAT GATEWAYS
output "eip-ngw" {
  value = "${aws_eip.eip-ngw.*.id}"
}

#OUTPUT OF NAT-GATEWAYS
output "ngw" {
  value = "${aws_nat_gateway.ngw.*.id}"
}

#OUTPUT OF PRIVATE SUBNET IDS
output "private-subnet-ids" {
  description = "Private Subnets IDS"
  value = "${aws_subnet.private-subnets.*.id}"
}

#OUTPUT OF PUBLIC SUBNET ASSOCIATION WITH PUBLIC ROUTE TABLES
output "public-association" {
  value = "${aws_route_table_association.public-association.*.id}"
}

#OUTPUT OF PUBLIC ROUTES ID
output "aws-route-table-public-routes-id" {
  value = "${aws_route_table.public-routes.*.id}"
}

#OUTPUT OF REGION AZS
output "aws-availability-zones" {
  value = "${data.aws_availability_zones.azs.names}"
}

#OUTPUT OF PRIVATE ROUTE TABLE IDS
output "aws-route-table-private-routes-id" {
  value = "${aws_route_table.private-routes.*.id}"
}
