resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns
  enable_dns_hostnames = var.enable_hostnames

  tags = merge(
    local.common_tags, var.primary_extra_tags,
    {
      "Name" = "${var.environment}-${var.name}-vpc"
    }
  )
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidr)
  availability_zone = element(var.availability_zones, count.index)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidr, count.index)

  tags = merge(
    local.common_tags, var.primary_extra_tags,
    {
      "Name" = "${var.environment}-${var.name}-public-subnet"
    }
  )
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr)
  availability_zone = element(var.availability_zones, count.index)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidr, count.index)

  tags = merge(
    local.common_tags, var.primary_extra_tags,
    {
      "Name" = "${var.environment}-${var.name}-private-subnet"
    }
  )
}

#Create custom route table for public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw
  }
  lifecycle {
    ignore_changes = all
  }
  tags = merge(
    local.common_tags, var.primary_extra_tags,
    {
      "Name" = "${var.environment}-${var.name}-public-route-table"
    }
  )
}

#Associate the public subnets to the public route table
resource "aws_route_table_association" "public_route_table_association" {
  count          = length(aws_subnet.public.*.id)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

#Create custom route table for private subnets
## need to verify the private subnet is associated with the nat in its AZ!
## I should only create as many tables as there are NAT devices, and priority is for the subnet to route to the NAT
##   in its AZ 'if' it exists
resource "aws_route_table" "private_route_table" {
  count  = length(var.natgw_ids)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(var.natgw_ids, count.index)
  }
  lifecycle {
    ignore_changes = all
  }
  tags = merge(
    local.common_tags, var.primary_extra_tags,
    {
      "Name" = "${var.environment}-${var.name}-private-route-table"
    }
  )
}

#Associate the private subnets to a private route table
resource "aws_route_table_association" "private_route_table_association" {
  count          = length(aws_subnet.private.*.id)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private_route_table.*.id, count.index)
}

