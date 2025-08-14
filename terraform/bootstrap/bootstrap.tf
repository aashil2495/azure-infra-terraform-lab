resource "azurerm_resource_group" "rg" {
  name     = "rg-tfstate"
  location = var.location
}

resource "azurerm_storage_account" "tfstatefile_stg" {
  name                     = "stgprojnametfstate"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  allow_nested_items_to_be_public = false

  lifecycle {
    ignore_changes = [tags]
  }

  is_hns_enabled = true
}

resource "azurerm_storage_container" "container_tfstate" {
  name     = "terraform-statefile-store"
  storage_account_id    = azurerm_storage_account.tfstatefile_stg.id
  container_access_type = "private"
 }