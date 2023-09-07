#****************************************************************************
# main.tf
# Terraform script to create AWS security group for freeswitch
# Author: Elias Sun (eliassun@gmail.com)
#****************************************************************************

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group" "service" {
  count       = var.byo_sg == false ? var.sg_count : 0
  name        = var.sg_count > 1 ? "${var.prefix}-service-${count.index + 1}-${var.tag}" : "${var.prefix}-service-${var.tag}"
  description = "Security group for service"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags,
    { Name = "${var.prefix}-service-${var.tag}" }
  )

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_security_group" "service_selected" {
  count = var.byo_sg ? length(var.byo_service_sg_id) : 0
  id    = element(var.byo_service_sg_id, count.index)
}

resource "aws_security_group_rule" "service_ingress_icmp" {
  count             = var.byo_sg == false ? var.sg_count : 0
  description       = "Allow ICMP to service VM"
  from_port         = 8
  to_port           = 0
  protocol          = "icmp"
  security_group_id = aws_security_group.service[count.index].id
  cidr_blocks       = var.tcp_cidrs
  type              = "ingress"
}

resource "aws_security_group_rule" "service_ingress_ssh" {
  count             = var.byo_sg == false ? var.sg_count : 0
  description       = "Allow SSH to service VM"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.service[count.index].id
  cidr_blocks       = concat([data.aws_vpc.selected.cidr_block], var.ssh_cidr)
  type              = "ingress"
}

resource "aws_security_group_rule" "service_ingress_msrp_block" {
  count       = var.byo_sg == false ? var.sg_count : 0
  from_port   = var.msrp_tcp_from_port
  to_port     = var.msrp_tcp_to_port
  protocol    = "tcp"
  cidr_blocks = var.tcp_cidrs
  type        = "ingress"
  security_group_id = aws_security_group.service[count.index].id
}

resource "aws_security_group_rule" "service_ingress_sip_tcp_default" {
  count       = var.byo_sg == false ? var.sg_count : 0
  from_port   = var.sip_tcp_from_port
  to_port     = var.sip_tcp_to_port
  protocol    = "tcp"
  cidr_blocks = var.tcp_cidrs
  type        = "ingress"
  security_group_id = aws_security_group.service[count.index].id
}

resource "aws_security_group_rule" "service_ingress_sip_tcp_nat" {
  count       = var.byo_sg == false ? var.sg_count : 0
  from_port   = var.sip_tcp_nat_from_port
  to_port     = var.sip_tcp_nat_to_port
  protocol    = "tcp"
  cidr_blocks = var.tcp_cidrs
  type        = "ingress"
  security_group_id = aws_security_group.service[count.index].id
}

resource "aws_security_group_rule" "service_ingress_sip_tcp_external" {
  count       = var.byo_sg == false ? var.sg_count : 0
  from_port   = var.sip_tcp_ext_from_port
  to_port     = var.sip_tcp_ext_to_port
  protocol    = "tcp"
  cidr_blocks = var.tcp_cidrs
  type        = "ingress"
  security_group_id = aws_security_group.service[count.index].id
}

resource "aws_security_group_rule" "service_ingress_esl_tcp_external" {
  count       = var.byo_sg == false ? var.sg_count : 0
  from_port   = var.sip_tcp_esl_from_port
  to_port     = var.sip_tcp_esl_to_port
  protocol    = "tcp"
  cidr_blocks = var.tcp_cidrs
  type        = "ingress"
  security_group_id = aws_security_group.service[count.index].id
}

resource "aws_security_group_rule" "service_ingress_websocket1_tcp" {
  count       = var.byo_sg == false ? var.sg_count : 0
  from_port   = var.sig_tcp_ws1_from_port
  to_port     = var.sig_tcp_ws1_to_port
  protocol    = "tcp"
  cidr_blocks = var.tcp_cidrs
  type        = "ingress"
  security_group_id = aws_security_group.service[count.index].id
}

resource "aws_security_group_rule" "service_ingress_websocket2_tcp" {
  count       = var.byo_sg == false ? var.sg_count : 0
  from_port   = var.sig_tcp_ws2_from_port
  to_port     = var.sig_tcp_ws2_to_port
  protocol    = "tcp"
  cidr_blocks = var.tcp_cidrs
  type        = "ingress"
  security_group_id = aws_security_group.service[count.index].id
}

resource "aws_security_group_rule" "service_ingress_verto_tcp_block" {
  count       = var.byo_sg == false ? var.sg_count : 0
  from_port   = var.verto_tcp_from_port
  to_port     = var.verto_tcp_to_port
  protocol    = "tcp"
  cidr_blocks = var.tcp_cidrs
  type        = "ingress"
  security_group_id = aws_security_group.service[count.index].id
}

resource "aws_security_group_rule" "service_ingress_rtp_listen_block" {
  count       = var.byo_sg == false ? var.sg_count : 0
  from_port   = var.rtp_from_port
  to_port     = var.rtp_to_port
  protocol    = "udp"
  cidr_blocks = var.udp_cidrs
  type        = "ingress"
  security_group_id = aws_security_group.service[count.index].id
}

resource "aws_security_group_rule" "service_ingress_stun_listen_block" {
  count       = var.byo_sg == false ? var.sg_count : 0
  from_port   = var.stun_from_port
  to_port     = var.stun_to_port
  protocol    = "udp"
  cidr_blocks = var.udp_cidrs
  type        = "ingress"
  security_group_id = aws_security_group.service[count.index].id
}
