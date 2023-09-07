#****************************************************************************
# outputs.tf
# Author: Elias Sun (eliassun@gmail.com)
#****************************************************************************

output "vpc_id" {
  description = "The VPC ID."
  value       = module.network.vpc_id
}

output "internet_gateway_id" {
  description = "The Internet Gateway ID."
  value       = module.network.internet_gateway_id
}

output "service_security_group_id" {
  description = "The Service Security Group ID."
  value       = module.fs_sg.service_security_group_id
}


output "key_name" {
  description = "The key name used for the EC2 instances."
  value       = aws_key_pair.key_pair.key_name
}

output "private_key" {
  description = "The private key content in PEM format."
  value       = tls_private_key.key.private_key_pem
  sensitive   = true
}

output "private_key_file" {
  description = "The file path of the private key in PEM format."
  value       = local_file.ssh_private_key.filename
}

output "fs" {
  value = "If this is 1st time to deploy, it needs to take about 30 minutes for freeswitch to finish the installation..."
}

locals {
  scp_progress = <<EOT
scp -i ${var.prefix}-key-${random_string.tag.result}.pem ubuntu@${module.freeswitch.freeswitch_public_ips[0]}:/home/ubuntu/install/progress.log ./
cat ./progress.log
scp -i ${var.prefix}-key-${random_string.tag.result}.pem ubuntu@${module.freeswitch.freeswitch_public_ips[0]}:/home/ubuntu/install/freeswitch.status ./
cat ./freeswitch.status
EOT

  ssh_instructions = <<EOT

*****Disclaimer*****
This Terraform configuration generates and stores critical files in the "services" directory. It is crucial to backup and secure these files as they are necessary for accessing and managing the infrastructure:

1. Terraform State File (terraform.tfstate): This file contains the state of the managed infrastructure and configuration. Terraform uses this file to determine which changes need to be applied to the infrastructure. If this file is lost, it will not be possible to make incremental changes to the environment resources without manually importing the state back into Terraform.

2. SSH Private Key File (.pem): This configuration creates a new local private/public key pair for VM access. Without the private key, it will not be possible to access the VMs remotely once they are deployed.

It is recommended to store these files in a secure location and implement proper backup strategies to prevent data loss. DO NOT delete or lose these files.


*****FreeSWITCH IPs*****

Public:
${join("\n", module.freeswitch.freeswitch_public_ips[*])}


Private:
${join("\n", module.freeswitch.freeswitch_private_ips[*])}


***SSH Instructions***

1) SSH to the FreeSWITCH instance:
ssh -i ${var.prefix}-key-${random_string.tag.result}.pem ubuntu@<FreeSWITCH_Instance_Public_IP>

Replace <FreeSWITCH_Instance_Public_IP> with the public IP address of the FreeSWITCH instance.
e.g.:
ssh -i ${var.prefix}-key-${random_string.tag.result}.pem ubuntu@${module.freeswitch.freeswitch_public_ips[0]}


EOT
}

output "ssh_instructions" {
  description = "Instructions for accessing the deployed infrastructure via SSH."
  value       = local.ssh_instructions
}

resource "local_file" "ssh_instructions" {
  content  = local.ssh_instructions
  filename = "../ssh_instructions.txt"
}

resource "local_file" "progress_log" {
  content  = local.scp_progress
  filename = "../install_progress"
}
