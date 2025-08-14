resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 3
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "rg-data-infra" {
  name     = "rg-scus-${var.environment}-data-infra"
  location = var.location
}

resource "azurerm_resource_group" "transit_rg" {
  name     = "rg-scus-${var.environment}-dbrx-mgnd-infra"
  location = var.location
}



locals {
  prefix   = join("-", [var.prefix, "${random_string.naming.result}"])
  dbfsname = join("", ["stg", "${random_string.naming.result}"]) // dbfs name must not have special chars
  tenant_id = data.azurerm_client_config.current.tenant_id
  }