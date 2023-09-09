output "arn" {
  value = [aws_lb_target_group.ssh_tg.arn, aws_lb_target_group.sip_tg.arn]
}

output "alb" {
  value = aws_lb.nlb
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.nlb.dns_name
}
