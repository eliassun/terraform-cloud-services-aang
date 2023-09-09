#****************************************************************************
# variables.tf
# Author: Elias Sun (eliassun@gmail.com)
#****************************************************************************

variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "aws_session_token" {
  type = string
}

variable "region" {
  type = string
}

variable "owner" {
  description = "Owner of the resources, typically your name or your organization's name"
  type        = string
  default     = "e.s."
}

variable "memo" {
  description = "A memo or note that you want to associate with the resources"
  type        = string
  default     = "fs"
}

variable "tls_key_algorithm" {
  description = "The algorithm to use for the private key"
  type        = string
  default     = "RSA"
}

variable "prefix" {
  description = "Prefix for the resources names"
  type        = string
  default     = "ser"
}

variable "az_count" {
  description = "Number of Availability Zones to use"
  type        = number
  default     = 1
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnets_nat" {
  description = "List of public subnets within the VPC"
  type        = list(string)
  default     = ["10.1.50.0/24" ]
}

variable "service_subnets" {
  description = "List of service subnets within the VPC"
  type        = list(string)
  default     = ["10.1.51.0/24"]
}

variable "instance_type" {
  description = "The instance type of the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "bastion_allow_ssh" {
  description = "Allow which IP cidr to ssh"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}