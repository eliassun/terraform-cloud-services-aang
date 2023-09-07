#****************************************************************************
# outputs.tf
# Author: Elias Sun (eliassun@gmail.com)
#****************************************************************************


output "freeswitch_public_ips" {
    value = aws_eip.service_eip[*].public_ip
}

output "freeswitch_private_ips" {
    value = aws_instance.freeswitch[*].private_ip
}

output "freeswitch_ids" {
    value = aws_instance.freeswitch[*].id
}

