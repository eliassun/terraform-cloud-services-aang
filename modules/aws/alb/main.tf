#****************************************************************************
# main.tf
# Author: Elias Sun (eliassun@gmail.com)
# Create ALB
#****************************************************************************

resource "aws_lb" "alb" {
  name                             = "${var.prefix}-alb-${var.tag}"
  internal                         = false
  load_balancer_type               = "application"
  subnets                          = var.subnets
  enable_http2                     = true
  security_groups                  = var.sg
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
  tags = merge(var.tags, { Name = "${var.prefix}-alb-${var.tag}" })
}