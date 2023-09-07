#****************************************************************************
# variables.tf
# Author: Elias Sun (eliassun@gmail.com)
#****************************************************************************

variable "prefix" {
  type        = string
  description = "A prefix to associate to all the Cloud Connector Security Group module resources"
}

variable "tag" {
  type        = string
  description = "A tag to associate to all the Cloud Connector Security Group module resources"
}

variable "tags" {
  type        = map(string)
  description = "Populate any custom user defined tags from a map"
}

variable "vpc_id" {
  type        = string
  description = "Cloud Connector VPC ID"
}

variable "sg_count" {
  type        = number
  description = "Default number of security groups to create"
  default     = 1
}

variable "msrp_tcp_from_port" {
  type        = number
  description = "Service TCP listen port"
  default     = "2855"
}

variable "msrp_tcp_to_port" {
  type        = number
  description = "Service TCP listen port"
  default     = "2856"
}

variable "h323_tcp_from_port" {
  type        = number
  description = "H.323 Call Signaling"
  default     = 1720
}

variable "h323_tcp_to_port" {
  type        = number
  description = "H.323 Call Signaling"
  default     = 1720
}

variable "sip_tcp_from_port" {
  type        = number
  description = "Used for SIP signaling (Standard SIP Port, for default Internal Profile)"
  default     = 5060
}

variable "sip_tcp_to_port" {
  type        = number
  description = "Used for SIP signaling (Standard SIP Port, for default Internal Profile)"
  default     = 5060
}

variable "sip_tcp_nat_from_port" {
  type        = number
  description = "Used for SIP signaling (For default NAT Profile)"
  default     = 5070
}

variable "sip_tcp_nat_to_port" {
  type        = number
  description = "Used for SIP signaling (For default NAT Profile)"
  default     = 5070
}

variable "sip_tcp_ext_from_port" {
  type        = number
  description = "Used for SIP signaling (For default External Profile)"
  default     = 5080
}

variable "sip_tcp_ext_to_port" {
  type        = number
  description = "Used for SIP signaling (For default External Profile)"
  default     = 5080
}

variable "sip_tcp_esl_from_port" {
  type        = number
  description = "Used for mod_event_socket *"
  default     = 8021
}

variable "sip_tcp_esl_to_port" {
  type        = number
  description = "Used for mod_event_socket *"
  default     = 8021
}

variable "sig_tcp_ws1_from_port" {
  type        = number
  description = "Used for WebRTC"
  default     = 5066
}

variable "sig_tcp_ws1_to_port" {
  type        = number
  description = "Used for WebRTC"
  default     = 5066
}

variable "sig_tcp_ws2_from_port" {
  type        = number
  description = "Used for WebRTC"
  default     = 7443
}

variable "sig_tcp_ws2_to_port" {
  type        = number
  description = "Used for WebRTC"
  default     = 7443
}

variable "verto_tcp_from_port" {
  type        = number
  description = "Used for Verto"
  default     = 8081
}

variable "verto_tcp_to_port" {
  type        = number
  description = "Used for Verto"
  default     = 8082
}

variable "rtp_from_port" {
  type        = number
  description = "Used for audio/video data in SIP, Verto, and other protocols"
  default     = 16384
}

variable "rtp_to_port" {
  type        = number
  description = "Used for audio/video data in SIP, Verto, and other protocols"
  default     = 32768
}

variable "stun_from_port" {
  type        = number
  description = "Used for NAT traversal"
  default     = 3478
}

variable "stun_to_port" {
  type        = number
  description = "Used for NAT traversal"
  default     = 3479
}

variable "tcp_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "udp_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "byo_sg" {
  type        = bool
  description = "Bring your own Security Group for Cloud Connector. Setting this variable to true will effectively instruct this module to not create any resources and only reference data resources from values provided in byo_mgmt_security_group_id and byo_service_security_group_id"
  default     = false
}

variable "byo_service_sg_id" {
  type        = list(string)
  description = "Service Security Group ID for Cloud Connector association"
  default     = null
}

variable "ssh_cidr" {
  type = list(string)
}