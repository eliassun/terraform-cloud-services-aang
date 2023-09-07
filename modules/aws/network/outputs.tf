#****************************************************************************
# outputs.tf
# Author: Elias Sun (eliassun@gmail.com)
#****************************************************************************

output "vpc_id" {
  description = "VPC ID"
  value       = try(data.aws_vpc.vpc[0].id, aws_vpc.vpc[0].id)
}

output "service_subnet_ids" {
  description = "Service subnet ids"
  value       = data.aws_subnet.service_subnet_selected[*].id
}

output "public_subnet_ids" {
  description = "Public Subnet ID"
  value       = aws_subnet.pub[*].id
}


output "nat_gateway_ips" {
  description = "NAT Gateway Public IP"
  value       = data.aws_nat_gateway.ngw[*].public_ip
}

output "pub_subnet_route_table_ids" {
  description = "Public subnet route table ids"
  value       = aws_route_table_association.pub_rta[*].route_table_id
}

output "internet_gateway_id" {
  value = data.aws_internet_gateway.igw
}