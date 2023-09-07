#****************************************************************************
# Author: eliassun@gmail.com
#****************************************************************************

resource "aws_lb_target_group" "tg" {
  name                 = var.tg_name
  port                 = 6081
  protocol             = "GENEVE"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = var.dereg_delay

  health_check {
    port                = var.probe_port
    protocol            = "HTTP"
    path                = var.healthy_check_path
    interval            = var.check_interval
    healthy_threshold   = var.healthy_count
    unhealthy_threshold = var.unhealthy_count
  }

  target_failover {
    on_deregistration = var.rebalance == true ? "rebalance" : "no_rebalance"
    on_unhealthy      = var.rebalance == true ? "rebalance" : "no_rebalance"
  }

  stickiness {
    enabled = var.stickiness == "5-tuple" ? false : true
    type    = var.stickiness == "2-tuple" ? "source_ip_dest_ip" : "source_ip_dest_ip_proto"
  }
}

resource "aws_lb_target_group_attachment" "tga_small" {
  count            = var.instance_size == "small" ? length(var.small_ips) : 0
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = element(var.small_ips, count.index)
}

# GWLB Target Group to Local Listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = var.gwlb_name
  port              = 6081
  protocol          = "GENEVE"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body  = "OK"
      status_code   = 200
    }
  }

  action {
    type                 = "forward"
    target_group_arn     = aws_lb_target_group.tg.arn
    stickiness {
      type            = var.stickiness
      duration        = 60
      enabled         = true
    }
  }

  tags = var.tags
}
