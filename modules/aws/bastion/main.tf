#****************************************************************************
# main.tf
# Author: Elias Sun (eliassun@gmail.com)
# Terraform script to create a bastion host on AWS
#****************************************************************************

# Fetch the AWS VPC details using the provided VPC ID
data "aws_vpc" "vpc" {
  id = var.vpc_id
}

# Fetch the latest Ubuntu 22.04 AMI for the bastion host
data "aws_ami" "ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# Create a security group for the bastion host with rules for SSH and internet access
resource "aws_security_group" "sg" {
  name        = "${var.prefix}-sg-${var.tag}"
  description = "Allow SSH access to bastion host and outbound internet access"
  vpc_id      = data.aws_vpc.vpc.id
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(var.tags, { Name = "${var.prefix}-sg-${var.tag}" })
}

# Rule to allow SSH access from specific CIDR blocks
resource "aws_security_group_rule" "ssh" {
  protocol          = "TCP"
  from_port         = 22
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = var.ssh_cidr
  security_group_id = aws_security_group.sg.id
}

# Rule to allow outbound internet access
resource "aws_security_group_rule" "internet" {
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

# Rule to allow internal VPC communication
resource "aws_security_group_rule" "intranet" {
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  type              = "egress"
  cidr_blocks       = [data.aws_vpc.vpc.cidr_block]
  security_group_id = aws_security_group.sg.id
}

# Define the assume role policy for the bastion host
data "aws_iam_policy_document" "policy" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create an IAM role for the bastion host
resource "aws_iam_role" "role" {
  count              = var.enable_iam ? 1 : 0
  name               = "${var.prefix}-role-${var.tag}"
  assume_role_policy = data.aws_iam_policy_document.policy.json
  tags = merge(var.tags)
}

# Attach the SSM Managed Instance Core policy to the IAM role
resource "aws_iam_role_policy_attachment" "ssm" {
  count      = var.enable_iam ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/${var.ssm_policy}"
  role       = aws_iam_role.role[0].name
}

# Create an IAM instance profile and assign the role to it
resource "aws_iam_instance_profile" "profile" {
  count = var.enable_iam ? 1 : 0
  name  = "${var.prefix}-profile-${var.tag}"
  role  = aws_iam_role.role[0].name
  tags  = merge(var.tags)
}

# Create the bastion host instance
resource "aws_instance" "bastion_iam" {
  count                       = var.enable_iam ? 1 : 0
  ami                         = data.aws_ami.ami.id
  instance_type               = var.type
  key_name                    = var.key
  subnet_id                   = var.subnet
  vpc_security_group_ids      = [aws_security_group.sg.id]
  iam_instance_profile        = aws_iam_instance_profile.profile[0].name
  associate_public_ip_address = true
  root_block_device {
    volume_size           = var.disk
    delete_on_termination = true
  }
  lifecycle {
    ignore_changes = [ami]
  }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  tags = merge(var.tags, { Name = "${var.prefix}-bastion-${var.tag}" })
}

# Create the bastion host instance
resource "aws_instance" "bastion_no_iam" {
  count                       = !var.enable_iam ? 1 : 0
  ami                         = data.aws_ami.ami.id
  instance_type               = var.type
  key_name                    = var.key
  subnet_id                   = var.subnet
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  root_block_device {
    volume_size           = var.disk
    delete_on_termination = true
  }
  lifecycle {
    ignore_changes = [ami]
  }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  tags = merge(var.tags, { Name = "${var.prefix}-bastion-${var.tag}" })
}

data "aws_instance" "bastion" {
    filter {
      name   = "instance-id"
      values = [try(aws_instance.bastion_iam[0].id, aws_instance.bastion_no_iam[0].id)]
    }
}
