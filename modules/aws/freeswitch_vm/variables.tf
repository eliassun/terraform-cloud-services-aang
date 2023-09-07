#****************************************************************************
# variables.tf
# Author: Elias Sun (eliassun@gmail.com)
#****************************************************************************

variable "prefix" {
  type        = string
  description =  "A prefix to associate with all the network module resources."
  default     = null
}

variable "tag" {
  type        = string
  description = "A tag to associate with all the network module resources."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Populate any custom user-defined tags from a map."
  default     = {}
}

variable "instance_count" {
  type        = number
  description = "A prefix to associate with all the network module resources."
  default     = 1
}

variable "subnet_id" {
  description = "a subnet for all service instances"
}

variable "sg" {
  description = "security group"
}

variable "service_private_ips" {
  type        = list(string)
  description = "A list of private ips for services"
  default     = []
}

variable "igw" {
  description = "IGW to attach service"
}

variable "type" {
  type        = string
  description = "instance type"
}


variable "key_name" {
  type        = string
  description = "AWS SSH key file name"
}
