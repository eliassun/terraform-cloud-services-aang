#****************************************************************************
# Author: eliassun@gmail.com
#****************************************************************************

variable "vpc_id" {
  type        = string
  description = "VPC ID for Cloud Connector"
}

variable "small_ips" {
  type        = list(string)
  description = "Service IPs for Small Cloud Connector instances"
  default     = []
}

variable "med_lrg_1_ips" {
  type        = list(string)
  description = "Service-1 IPs for Medium/Large Cloud Connector instances"
  default     = []
}

variable "med_lrg_2_ips" {
  type        = list(string)
  description = "Service-2 IPs for Medium/Large Cloud Connector instances"
  default     = []
}

variable "lrg_3_ips" {
  type        = list(string)
  description = "Service-3 IPs for Large Cloud Connector instances"
  default     = []
}

variable "probe_port" {
  type        = number
  description = "Listener port for HTTP probe from GWLB Target Group"
  default     = 50000
  validation {
    condition = (
      tonumber(var.probe_port) == 80 ||
      (tonumber(var.probe_port) >= 1024 && tonumber(var.probe_port) <= 65535)
    )
    error_message = "Probe port must be 80 or between 1024-65535."
  }
}

variable "check_interval" {
  type        = number
  description = "Health check probing interval in seconds"
  default     = 10
}

variable "healthy_check_path" {
  type        = string
  description = "Health check path"
  default     = '/'
}

variable "healthy_count" {
  type        = number
  description = "Successful health checks before a target is considered healthy"
  default     = 2
}

variable "unhealthy_count" {
  type        = number
  description = "Unsuccessful health checks before a target is considered unhealthy"
  default     = 3
}

variable "cross_zone" {
  type        = bool
  description = "Enable GWLB cross zone load balancing"
  default     = false
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for Cloud Connector"
}

variable "tags" {
  type        = map(string)
  description = "Custom user-defined tags"
  default     = {}
}

variable "instance_size" {
  type        = string
  description = "Instance size as defined in the Connector portal provisioning template"
  default     = "small"
  validation {
    condition = (
      var.instance_size == "small" ||
      var.instance_size == "medium" ||
      var.instance_size == "large"
    )
    error_message = "Instance size must be 'small', 'medium', or 'large'."
  }
}

variable "gwlb_name" {
  type        = string
  description = "GWLB resource and tag name"
  validation {
    condition     = length(var.gwlb_name) <= 32 && can(regex("^[A-Za-z0-9-]+$", var.gwlb_name))
    error_message = "GWLB name must be up to 32 characters, alphanumeric or hyphen, and not start/end with a hyphen."
  }
}

variable "tg_name" {
  type        = string
  description = "GWLB Target Group resource name"
  validation {
    condition     = length(var.tg_name) <= 32 && can(regex("^[A-Za-z0-9-]+$", var.tg_name))
    error_message = "Target Group name must be up to 32 characters, alphanumeric or hyphen, and not start/end with a hyphen."
  }
}

variable "dereg_delay" {
  type        = number
  description = "Deregistration delay for Elastic Load Balancing in seconds"
  default     = 0
}

variable "stickiness" {
  type        = string
  description = "Flow stickiness: '5-tuple', '3-tuple', or '2-tuple'"
  default     = "5-tuple"
  validation {
    condition = (
      var.stickiness == "2-tuple" ||
      var.stickiness == "3-tuple" ||
      var.stickiness == "5-tuple"
    )
    error_message = "Stickiness must be '5-tuple', '3-tuple', or '2-tuple'."
  }
}

variable "rebalance" {
  type        = bool
  description = "Rebalance existing flows when a target is deregistered/unhealthy"
  default     = true
}
