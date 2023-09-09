output "az_in_asg" {
  description = "Availability zones for ASG"
  value       = flatten(aws_autoscaling_group.asg[*].availability_zones)
}

output "asg_groups" {
  description = "Autoscaling group ID"
  value       = aws_autoscaling_group.asg[*].id
}

output "launch_template_id" {
  description = "ASG Launch Template ID"
  value       = aws_launch_template.tmpl.id
}

output "public_ips" {
  description = "Public IP addresses of filtered instances"
  value       = data.aws_instances.asg_instances.public_ips
}

output "private_ips" {
  description = "Private IP addresses of filtered instances"
  value       = data.aws_instances.asg_instances.private_ips
}

output "asg_instances" {
  value = data.aws_instances.asg_instances
}