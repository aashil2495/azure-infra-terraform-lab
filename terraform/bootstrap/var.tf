variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  type        = string
  description = "(Required) The location for the resources in this module"
  default="southcentralus"
}