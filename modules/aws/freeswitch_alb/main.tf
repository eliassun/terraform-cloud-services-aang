#****************************************************************************
# main.tf
# Author: Elias Sun (eliassun@gmail.com)
# Terraform script to create a ALB on AWS
#****************************************************************************
resource "aws_lb" "nlb" {
  name               = "${var.prefix}-nlb-${var.tag}"
  internal           = false
  load_balancer_type = "network"  # NLB
  security_groups    = var.sg
  subnets            = var.subnet_id
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = var.cross_az ? true : false
  tags = merge(var.tags, { Name = "${var.prefix}-nlb-${var.tag}" })
}

# SSH Target Group
resource "aws_lb_target_group" "ssh_tg" {
  name     = "${var.prefix}-ssh-tg-${var.tag}"
  port     = 22
  protocol = "TCP"
  vpc_id   = var.vpc
  health_check {
    interval            = 30
    port                = "22"
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
  }
  tags = merge(var.tags, { Name = "${var.prefix}-ssh-tg-${var.tag}" })
}

# SIP Target Group
resource "aws_lb_target_group" "sip_tg" {
  name     = "${var.prefix}-sip-tg-${var.tag}"
  port     = 5060
  protocol = "TCP"
  vpc_id   = var.vpc
  health_check {
    interval            = 30
    port                = "5060"
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
  }
  tags = merge(var.tags, { Name = "${var.prefix}-sip-tg-${var.tag}" })
}

# SSH Listener
resource "aws_lb_listener" "ssh_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 22
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ssh_tg.arn
  }
}

# SIP Listener
resource "aws_lb_listener" "sip_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 5060
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sip_tg.arn
  }
}
