#########
# Labels
########

module "label" {
  source     = "../terraform-label"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags

}

# Creating VPC

resource "aws_vpc" "vpc" {
  count = var.enabled ? 1 : 0
  cidr_block           = var.vpc-cidr
  instance_tenancy     = var.instance-tenancy
  enable_dns_support   = var.enable-dns-support
  enable_dns_hostnames = var.enable-dns-hostnames

  tags = merge(
  module.label.tags,
  map(
  "Location", var.vpc-location
  )
  )
}

# Creating an Internet Gateway

resource "aws_internet_gateway" "igw" {
  count = var.enabled && length(var.vpc-public-subnet-cidr) > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc[0].id



    tags = {

      Name = "${module.label.namespace}-${module.label.stage}-${var.internet-gateway-name}"

    }




}

# Public Subnets

resource "aws_subnet" "public-subnets" {
  count                   = var.enabled && length(var.vpc-public-subnet-cidr) > 0 ? length(var.vpc-public-subnet-cidr) : 0
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  cidr_block              = var.vpc-public-subnet-cidr[count.index]
  vpc_id                  = aws_vpc.vpc[0].id
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name     = "${module.label.namespace}-${module.label.stage}-${var.public-subnets-name}-${count.index + 1}"
  }
}

# Public Routes

resource "aws_route_table" "public-routes" {
  vpc_id = aws_vpc.vpc[0].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }
  route {
    cidr_block         = var.tgw-route-cidr
    transit_gateway_id = var.transit_gateway_id
  }
  tags = {
    Name = "${module.label.namespace}-${module.label.stage}-${var.public-subnet-routes-name}"
  }
}

# Associate/Link Public-Route With Public-Subnets

resource "aws_route_table_association" "public-association" {
  count          = var.enabled && length(var.vpc-public-subnet-cidr) > 0 ? length(var.vpc-public-subnet-cidr) : 0
  route_table_id = aws_route_table.public-routes.id
  subnet_id      = aws_subnet.public-subnets.*.id[count.index]
}

# Creating Private Subnets

resource "aws_subnet" "private-subnets" {
  count             = var.enabled && length(var.vpc-private-subnet-cidr) > 0 ? length(var.vpc-private-subnet-cidr) : 0
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  cidr_block        = var.vpc-private-subnet-cidr[count.index]
  vpc_id            = aws_vpc.vpc[0].id


  tags = {
    Name     = "${module.label.namespace}-${module.label.stage}-${var.private-subnet-name}-${count.index + 1}"
  }
}

# Elastic IP For NAT-Gate Way

resource "aws_eip" "eip-ngw" {
  count = var.enabled && var.total-nat-gateway-required > 0 ?  var.total-nat-gateway-required : 0
  tags = {
    Name = "${module.label.namespace}-${module.label.stage}-${var.eip-for-nat-gateway-name}-${count.index + 1}"
  }
}
# Creating NAT Gateways In Public-Subnets, Each NAT-Gateway Will Be In Diffrent AZ

resource "aws_nat_gateway" "ngw" {
  count         = var.enabled && var.total-nat-gateway-required > 0 ? var.total-nat-gateway-required : 0
  allocation_id = aws_eip.eip-ngw.*.id[count.index]
  subnet_id     = aws_subnet.public-subnets.*.id[count.index]
  tags = {
    Name = "${module.label.namespace}-${module.label.stage}-${var.nat-gateway-name}-${count.index + 1}"

  }
}

# Private Route-Table For Private-Subnets

resource "aws_route_table" "private-routes" {
  count  = var.enabled && length(var.vpc-private-subnet-cidr) > 0 ? length(var.vpc-private-subnet-cidr) : 0
  vpc_id = aws_vpc.vpc[0].id
  route {
    cidr_block         = var.private-route-cidr
    nat_gateway_id = element(aws_nat_gateway.ngw.*.id,count.index)
  }

  route {
    cidr_block         = var.tgw-route-cidr
    transit_gateway_id = var.transit_gateway_id
  }

  tags = {
    Name = "${module.label.namespace}-${module.label.stage}-${var.private-route-name}-${count.index + 1}"
  }

}



# Associate/Link Private-Routes With Private-Subnets

resource "aws_route_table_association" "private-routes-linking" {
  count          = var.enabled && length(var.vpc-private-subnet-cidr) > 0 ? length(var.vpc-private-subnet-cidr) : 0
  subnet_id      = aws_subnet.private-subnets.*.id[count.index]
  route_table_id = aws_route_table.private-routes.*.id[count.index]
}


##################
# Database subnet
##################
resource "aws_subnet" "database" {
  count = var.create_database_subnet_group && length(var.vpc-database_subnets-cidr) > 0 ? length(var.vpc-database_subnets-cidr) : 0
  cidr_block = var.vpc-database_subnets-cidr[count.index]
  vpc_id = aws_vpc.vpc[0].id
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = {
    Name     = "${module.label.namespace}-${module.label.stage}-${var.db-subnets-name}-${count.index + 1}"
  }
}

resource "aws_db_subnet_group" "database" {

  name        = lower(module.label.id)
  description = "Database subnet group for ${module.label.id}"
  count = var.create_database_subnet_group && length(var.vpc-database_subnets-cidr) > 0 && var.create_database_subnet_group ? 1 : 0
  subnet_ids = aws_subnet.database.*.id

  tags = {
    Name     = "${module.label.namespace}-${module.label.stage}-${var.db-subnets-group-name}-${count.index + 1}"
  }
}

# Database Route-Table For Database-Subnets

resource "aws_route_table" "database-routes" {
  count  = var.create_database_subnet_group && length(var.vpc-database_subnets-cidr) > 0 ? length(var.vpc-database_subnets-cidr) : 0
  vpc_id = aws_vpc.vpc[0].id
  route {
    cidr_block     = var.private-route-cidr
    nat_gateway_id = element(aws_nat_gateway.ngw.*.id,count.index)
  }

  route {
    cidr_block         = var.tgw-route-cidr
    transit_gateway_id = var.transit_gateway_id
  }

  tags = {
    Name = "${module.label.namespace}-${module.label.stage}-${var.db-routes-name}-${count.index + 1}"
  }

}


# Associate/Link Database-Routes With Database-Subnets
resource "aws_route_table_association" "database-routes-association" {
  count =  var.create_database_subnet_group && var.create_database_subnet_group && length(var.vpc-database_subnets-cidr) > 0 ? length(var.vpc-database_subnets-cidr) : 0
  subnet_id = element(aws_subnet.database.*.id,count.index )
  route_table_id = element(aws_route_table.database-routes.*.id,count.index )
}