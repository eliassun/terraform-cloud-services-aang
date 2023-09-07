#****************************************************************************
# main.tf
# Author: Elias Sun (eliassun@gmail.com)
# Terraform script to create a freeswitch service
#****************************************************************************

resource "random_string" "tag" {
  length  = 12
  upper   = false
  special = false
}

# Tags in Tags field of a resource
locals {
  tags = {
    owner = var.owner
    memo  = var.memo
  }
}

resource "tls_private_key" "key" {
  algorithm = var.tls_key_algorithm
}

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.prefix}-key-${random_string.tag.result}"
  public_key = tls_private_key.key.public_key_openssh
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "../${var.prefix}-key-${random_string.tag.result}.pem"
  file_permission = "0400"
}

module "network" {
  source            = "../../modules/aws/network"
  prefix            = var.prefix
  tag               = random_string.tag.result
  tags              = local.tags
  az_count          = var.az_count
  cidr              = var.vpc_cidr
  pub_subnets       = var.public_subnets_nat
  service_subnets   = var.service_subnets
  enable_service_public = true
}

module "fs_sg" {
  source      = "../../modules/aws/freeswitch_sg"
  prefix      = var.prefix
  tag         = random_string.tag.result
  tags        = local.tags
  vpc_id      = module.network.vpc_id
  ssh_cidr    = var.bastion_allow_ssh
}

module "freeswitch" {
  source      = "../../modules/aws/freeswitch_vm"
  prefix      = var.prefix
  tag         = random_string.tag.result
  tags        = local.tags
  type        = var.instance_type
  igw         = module.network.internet_gateway_id
  sg          = module.fs_sg.service_security_group_id
  subnet_id   = module.network.service_subnet_ids
  key_name    = aws_key_pair.key_pair.key_name
}
