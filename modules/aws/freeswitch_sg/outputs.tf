#****************************************************************************
# outputs.tf
# Author: Elias Sun (eliassun@gmail.com)
#****************************************************************************

output "service_security_group_id" {
  description = "Service Security Group ID"
  value       = var.byo_sg ? data.aws_security_group.service_selected[*].id : aws_security_group.service[*].id
}

output "service_security_group_arn" {
  description = "Service Instance Security Group ARN"
  value       = var.byo_sg ? data.aws_security_group.service_selected[*].arn : aws_security_group.service[*].arn
}
