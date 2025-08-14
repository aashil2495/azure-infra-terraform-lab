# Create Azure Storage Account (named with 'stg')
resource "azurerm_storage_account" "dp_stg" {
  name                     = "stg${replace(local.prefix, "-", "")}"
  resource_group_name      = azurerm_resource_group.rg-data-infra.name
  location                 = azurerm_resource_group.rg-data-infra.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  allow_nested_items_to_be_public = false

  lifecycle {
    ignore_changes = [tags]
  }

  is_hns_enabled = true
}

# Private Endpoint for Storage Account ('stg') using existing DNS zone
resource "azurerm_private_endpoint" "stg_private_endpoint" {
  name                = "pe-${var.environment}-stg-${local.prefix}"
  location            = azurerm_resource_group.rg-data-infra.location
  resource_group_name = azurerm_resource_group.rg-data-infra.name
  subnet_id           = azurerm_subnet.dp_plsubnet.id

  private_service_connection {
    name                           = "pe-stg-serv-conn-${var.environment}-projname-${local.prefix}"
    private_connection_resource_id = azurerm_storage_account.dp_stg.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "stg-private-dns-group-${var.environment}-projname-${local.prefix}"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdbfs_blob.id] # existing DNS zone
  }
}

resource "azurerm_storage_container" "stg_medallion" {
   for_each = toset(["raw", "bronze", "silver", "gold","test-container"])
   name     = "${each.key}"
   storage_account_id    = azurerm_storage_account.dp_stg.id
   container_access_type = "private"
 }

