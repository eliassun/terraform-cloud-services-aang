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

variable "vpc" {
  description = "vpc id"
}

variable "cross_az" {
  type    = bool
  default = false
}