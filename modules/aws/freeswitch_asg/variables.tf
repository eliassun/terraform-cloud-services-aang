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

variable "type" {
  type        = string
  description = "instance type"
}

variable "key_name" {
  type        = string
  description = "AWS SSH key file name"
}

variable "enable_imdsv2" {
  type    = bool
  default = false
}

variable "min_size" {
  type        = number
  description = "The minimum size of the auto scale group"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "The maximum size of the auto scale group"
  default     = 2
  validation {
    condition = (
      var.max_size >= 1 && var.max_size <= 10
    )
    error_message = "Input max_size must be set to a number between 1 and 10."
  }
}

variable "health_check_grace_period" {
  type        = number
  description = "(Optional, Default: 300) Time (in seconds) after instance comes into service before checking health"
  default     = 0
}

variable "reuse_on_scale_in" {
  type        = bool
  description = "Specifies whether instances in the Auto Scaling group can be returned to the warm pool on scale in. Default recommendation is true"
  default     = true
}

variable "tmp_ver" {
  type        = string
  description = "Launch template version. Can be version number, $Latest, or $Default"
  default     = "$Latest"
}

variable "health_check_type" {
  type        = string
  description = "EC2 or ELB. Controls how health checking is done"
  default     = "EC2"
  validation {
    condition = (
      var.health_check_type == "EC2" ||
      var.health_check_type == "ELB"
    )
    error_message = "EC2 or ELB is allowed"
  }
}

variable "protect_from_scale_in" {
  type        = bool
  description = "Allows setting instance protection. The autoscaling group will not select instances with this setting for termination during scale in events"
  default     = false
}

variable "wait_for_capacity_timeout" {
  type        = string
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
  default     = "0"
}

variable "heartbeat_timeout_launching" {
  type        = number
  default     = 80
}

variable "heartbeat_timeout_terminating" {
  type        = number
  default     = 180
}

