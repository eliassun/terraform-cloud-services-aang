#****************************************************************************
# outputs.tf
# Author: Elias Sun (eliassun@gmail.com)
#****************************************************************************

output "public_ip" {
  description = "The public IP address assigned to the bastion host, which can be used for external access."
  value       = data.aws_instance.bastion.public_ip
}

output "public_dns" {
  description = "The fully qualified domain name of the bastion host, resolving to the public IP address, suitable for SSH access."
  value       = data.aws_instance.bastion.public_dns
}
