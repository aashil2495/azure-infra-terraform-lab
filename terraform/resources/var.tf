variable "cidr_dp" {
  type        = string
  description = "(Required) The CIDR for the Azure Data Plane VNet"
  default="10.0.0.0/22"
}

variable "location" {
  type        = string
  description = "(Required) The location for the resources in this module"
  default="southcentralus"
}

variable "prefix" {
  type        = string
  description = "(Required) The prefix to use for all resources in this module"
  default="test"
}

variable "cidr_transit" {
  type        = string
  description = "(Required) The CIDR for the Azure transit VNet"
  default="10.0.0.0/22"
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "tenant_id"{
  description = "Azure tenant ID"
  type   = string
}

variable "environment" {
  type = string
  description = "Environment we are in"
}
