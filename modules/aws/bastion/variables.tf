#****************************************************************************
# variables.tf
# Author: Elias Sun (eliassun@gmail.com)
#****************************************************************************

variable "prefix" {
  type        = string
  description = "A prefix to be prepended to the names of created resources, useful for distinguishing between different deployments."
  default     = null
}

variable "tag" {
  type        = string
  description = "A unique identifier to be appended to the names of created resources, useful for distinguishing between instances within a deployment."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "A map of custom tags to be applied to the created resources, in addition to the standard ones."
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the bastion host will be launched."
}

variable "subnet" {
  type        = string
  description = "The ID of the public subnet where the bastion host will be launched."
}

variable "type" {
  type        = string
  description = "The EC2 instance type for the bastion host, which determines the size and performance characteristics of the host."
  default     = "t2.micro"
}

variable "disk" {
  type        = number
  description = "The size of the root volume for the bastion host, in gigabytes (GB)."
  default     = 10
}

variable "ssh_cidr" {
  type        = list(string)
  description = "A list of CIDR blocks representing trusted networks that are allowed SSH access to the bastion host."
  default     = ["0.0.0.0/0"]
}

variable "key" {
  type        = string
  description = "The name of the EC2 key pair to be used for SSH access to the bastion host."
}

variable "ssm_policy" {
  type        = string
  description = "The ARN of the IAM policy to be attached to the bastion host's IAM role, granting it permission to interact with AWS Systems Manager (SSM)."
  default     = "AmazonSSMManagedInstanceCore"
}

variable "enable_iam" {
  type    = bool
  default = false
}