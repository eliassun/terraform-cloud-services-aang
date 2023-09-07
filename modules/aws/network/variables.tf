#****************************************************************************
# variables.tf
# Author: Elias Sun (eliassun@gmail.com)
#****************************************************************************

variable "prefix" {
  type        = string
  description = "A prefix to associate with all the network module resources."
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

variable "cidr" {
  type        = string
  default     = "10.1.0.0/16"
}

variable "pub_subnets" {
  type        = list(string)
  default     = null
}

variable "service_subnets" {
  type        = list(string)
  default     = null
}

variable "az_count" {
  type        = number
  description = "Default number of subnets to create based on availability zone input."
  default     = 2
  validation {
    condition = (
      (var.az_count >= 1 && var.az_count <= 3)
    )
    error_message = "Input az_count must be set to a single value between 1 and 3. Note* some regions have greater than 3 AZs. Please modify az_count validation in variables.tf if you are utilizing more than 3 AZs in a region that supports it. https://aws.amazon.com/about-aws/global-infrastructure/regions_az/."
  }
}

variable "byo_vpc" {
  type        = bool
  description = "Bring your own AWS VPC for Cloud Connector."
  default     = false
}

variable "byo_vpc_id" {
  type        = string
  description = "User provided existing AWS VPC ID."
  default     = null
}

variable "byo_service_subnets" {
  type        = bool
  description = "Bring your own AWS Subnets for Cloud Connector."
  default     = false
}

variable "byo_service_subnet_ids" {
  type        = list(string)
  description = "User provided existing AWS Subnet IDs."
  default     = null
}

variable "byo_igw" {
  type        = bool
  description = "Bring your own AWS VPC for Cloud Connector."
  default     = false
}

variable "byo_igw_id" {
  type        = string
  description = "User provided existing AWS Internet Gateway ID."
  default     = null
}

variable "byo_ngw" {
  type        = bool
  description = "Bring your own AWS NAT Gateway(s) Cloud Connector."
  default     = false
}

variable "byo_ngw_ids" {
  type        = list(string)
  description = "User provided existing AWS NAT Gateway IDs."
  default     = null
}

variable "byo_public_subnets" {
  type        = bool
  description = "Public subnet for servers accessed from Internet"
  default     = null
}

variable "enable_ngw" {
  type    = bool
  default = false
}

variable "enable_service_public" {
  type    = bool
  default = false
}