// For DFS
resource "azurerm_private_endpoint" "dp_dbfspe_dfs" {
  name                = "pe-dp-dbfs-dfs-${var.environment}-projname-${local.prefix}"
  location            = azurerm_resource_group.rg-data-infra.location
  resource_group_name = azurerm_resource_group.rg-data-infra.name
  subnet_id           = azurerm_subnet.dp_plsubnet.id


  private_service_connection {
    name                           = "pe-dp-dbfs-dfs-serv-conn-${var.environment}-projname-${local.prefix}"
    private_connection_resource_id = join("", [azurerm_databricks_workspace.dp_workspace.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/${local.dbfsname}"])
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name                 = "dp-dbfs-dfs-private-dns-group-${var.environment}-projname-${local.prefix}"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdbfs_dfs.id]
  }
  depends_on = [azurerm_private_endpoint.dp_dpcp]
}

// for Blob
resource "azurerm_private_endpoint" "dp_dbfspe_blob" {
  name                = "pe-dp-dbfs-blob-${var.environment}-projname-${local.prefix}"
  location            = azurerm_resource_group.rg-data-infra.location
  resource_group_name = azurerm_resource_group.rg-data-infra.name
  subnet_id           = azurerm_subnet.dp_plsubnet.id

  private_service_connection {
    name                           = "pe-dp-dbfs-blob-serv-conn-${var.environment}-projname-${local.prefix}"
    private_connection_resource_id = join("", [azurerm_databricks_workspace.dp_workspace.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/${local.dbfsname}"])
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "dp-dbfs-blob-private-dns-group-${var.environment}-projname-${local.prefix}"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdbfs_blob.id]
  }
  depends_on = [azurerm_private_endpoint.dp_dbfspe_dfs]
}