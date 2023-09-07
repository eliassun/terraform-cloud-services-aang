#****************************************************************************
# main.tf
# Terraform script for creating a VPC network on AWS
# Author: Elias Sun (eliassun@gmail.com)
#****************************************************************************

data "aws_availability_zones" "az" {
  state = "available"
}

# VPC
resource "aws_vpc" "vpc" {
  count                = var.byo_vpc ? 0 : 1
  cidr_block           = var.cidr
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.prefix}-vpc-${var.tag}"
  })
}

data "aws_vpc" "vpc" {
  count = var.byo_vpc ? 1 : 0
  id    = var.byo_vpc_id
}

# IGW
resource "aws_internet_gateway" "igw" {
  count  = var.byo_igw ? 0 : 1
  vpc_id = try(data.aws_vpc.vpc[0].id, aws_vpc.vpc[0].id)

  tags = merge(var.tags, {
    Name = "${var.prefix}-igw-${var.tag}"
  })
}

data "aws_internet_gateway" "igw" {
  internet_gateway_id = var.byo_igw ? var.byo_igw_id : aws_internet_gateway.igw[0].id
}

# Create an Elastic IP and NAT Gateway for each availability zone if user is not bringing their own NAT Gateway
resource "aws_eip" "eip" {
  count      = var.byo_ngw ? 0 : length(aws_subnet.pub[*].id)
  vpc        = true
  depends_on = [data.aws_internet_gateway.igw]

  tags = merge(var.tags, {
    Name = "${var.prefix}-eip-az${count.index + 1}-${var.tag}"
  })
}

resource "aws_nat_gateway" "ngw" {
  count         = var.byo_ngw || !var.enable_ngw ? 0 : length(aws_subnet.pub[*].id)
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.pub[count.index].id
  depends_on    = [data.aws_internet_gateway.igw]

  tags = merge(var.tags, {
    Name = "${var.prefix}-natgw-az${count.index + 1}-${var.tag}"
  })
}

data "aws_nat_gateway" "ngw" {
  count = var.byo_ngw ? length(var.byo_ngw_ids) : length(aws_nat_gateway.ngw[*].id)
  id    = var.byo_ngw ? element(var.byo_ngw_ids, count.index) : aws_nat_gateway.ngw[count.index].id
}

# Create subnet for service network in different AZ per az_count
resource "aws_subnet" "service_subnet" {
  count = var.byo_service_subnets == false ? var.az_count : 0
  availability_zone = data.aws_availability_zones.az.names[count.index]
  cidr_block        = try(var.service_subnets[count.index], var.service_subnets[0])
  vpc_id            = try(data.aws_vpc.vpc[0].id, aws_vpc.vpc[0].id)

  tags = merge(var.tags,
    { Name = "${var.prefix}-cc-subnet-${count.index + 1}-${var.tag}" }
  )
}

data "aws_subnet" "service_subnet_selected" {
  count = var.byo_service_subnets == false ? var.az_count : length(var.byo_service_subnet_ids)
  id    = var.byo_service_subnets == false ? aws_subnet.service_subnet[count.index].id : element(var.byo_service_subnet_ids, count.index)
}

# Create public subnets within the VPC if user is not bringing their own NAT Gateway
resource "aws_subnet" "pub" {
  count             = var.byo_ngw ? 0 : length(data.aws_subnet.service_subnet_selected[*].id)
  availability_zone = data.aws_availability_zones.az.names[count.index]
  cidr_block        = var.byo_public_subnets != null ? element(var.byo_public_subnets, count.index) : try(var.pub_subnets[count.index+1], var.pub_subnets[0])
  vpc_id            = try(data.aws_vpc.vpc[0].id, aws_vpc.vpc[0].id)

  tags = merge(var.tags, {
    Name = "${var.prefix}-pub-${count.index + 1}-${var.tag}"
  })
}

# Create a public route table pointing to the Internet Gateway if user is not bringing their own NAT Gateway
resource "aws_route_table" "pub_rt" {
  count  = var.byo_ngw ? 0 : 1
  vpc_id = try(data.aws_vpc.vpc[0].id, aws_vpc.vpc[0].id)

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.igw.internet_gateway_id
  }

  tags = merge(var.tags, {
    Name = "${var.prefix}-pub-rt-${var.tag}"
  })
}

# Associate the public route table to the public subnets if user is not bringing their own NAT Gateway
resource "aws_route_table_association" "pub_rta" {
  count          = var.byo_ngw ? 0 : length(aws_subnet.pub[*].id)
  subnet_id      = aws_subnet.pub[count.index].id
  route_table_id = aws_route_table.pub_rt[0].id
}

resource "aws_route_table_association" "pub_ser_rta" {
  count          = var.byo_ngw || !var.enable_service_public? 0 : length(aws_subnet.pub[*].id)
  subnet_id      = data.aws_subnet.service_subnet_selected[count.index].id
  route_table_id = aws_route_table.pub_rt[0].id
}