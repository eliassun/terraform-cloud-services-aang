#****************************************************************************
# main.tf
# Author: Elias Sun (eliassun@gmail.com)
# Terraform script to create a ASG on AWS
#****************************************************************************


data "http" "install" {
  url = "https://raw.githubusercontent.com/eliassun/eliassun.github.io/main/services/freeswitch/install_001.sh"
  request_headers = {
    Accept = "text/plain"
  }
}

# Fetch the latest Ubuntu 20.04 AMI for the bastion host
data "aws_ami" "ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}


resource "aws_launch_template" "tmpl" {
  name          = "${var.prefix}-tmpl-${var.tag}"
  image_id      = data.aws_ami.ami.id
  instance_type = var.type
  key_name      = var.key_name
  user_data     = base64encode(tostring(data.http.install.response_body))

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${var.prefix}-ser-${var.tag}" })
  }

  tag_specifications {
    resource_type = "network-interface"
    tags          = merge(var.tags, { Name = "${var.prefix}-serv-${var.tag}" })
  }

  network_interfaces {
    description                 = "service interface"
    device_index                = 0
    security_groups             = var.sg
    associate_public_ip_address = true
  }


  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = var.enable_imdsv2 ? "required" : "optional"
    instance_metadata_tags = "enabled"
  }

  tags = merge(var.tags, { Name = "${var.prefix}-tmpl-${var.tag}" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  count                     = !var.alb? length(var.subnet_id) : 0
  name                      = "${var.prefix}-asg-${count.index + 1}-${var.tag}"
  vpc_zone_identifier       = [element(distinct(var.subnet_id), count.index)]
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  protect_from_scale_in     = var.protect_from_scale_in
  wait_for_capacity_timeout = var.wait_for_capacity_timeout

  launch_template {
    id      = aws_launch_template.tmpl.id
    version = var.tmp_ver
  }

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  timeouts {
    delete = "20m"
  }

  lifecycle {
    ignore_changes = [load_balancers, desired_capacity, target_group_arns]
  }

}

resource "aws_autoscaling_group" "asg_alb" {
  count                     = var.alb? length(var.subnet_id) : 0
  name                      = "${var.prefix}-asg-${count.index + 1}-${var.tag}"
  vpc_zone_identifier       = [element(distinct(var.subnet_id), count.index)]
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  protect_from_scale_in     = var.protect_from_scale_in
  wait_for_capacity_timeout = var.wait_for_capacity_timeout

  launch_template {
    id      = aws_launch_template.tmpl.id
    version = var.tmp_ver
  }

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  timeouts {
    delete = "20m"
  }

  lifecycle {
    ignore_changes = [load_balancers, desired_capacity, target_group_arns]
  }

  target_group_arns = var.alb_arn

  depends_on = [var.alb_obj]
}

resource "null_resource" "wait_for_asg_instances" {
  provisioner "local-exec" {
    command = "sleep 60" # waits for 60 seconds; adjust as needed
  }
  depends_on = [aws_autoscaling_group.asg, aws_autoscaling_group.asg_alb]
}


data "aws_instances" "asg_instances" {
  filter {
    name   = "tag:Name"
    values = ["${var.prefix}-ser-${var.tag}"]
  }
  depends_on = [null_resource.wait_for_asg_instances]
}
