resource "azurerm_private_endpoint" "front_pe" {
  name                = "pe-frontend-${var.environment}-projname-${local.prefix}"
  location            = azurerm_resource_group.transit_rg.location
  resource_group_name = azurerm_resource_group.transit_rg.name
  subnet_id           = azurerm_subnet.transit_plsubnet.id

  private_service_connection {
    name                           = "pe-frontend-serv-conn-${var.environment}-projname-${local.prefix}"
    private_connection_resource_id = azurerm_databricks_workspace.dp_workspace.id
    is_manual_connection           = false
    subresource_names              = ["databricks_ui_api"]
  }

  private_dns_zone_group {
    name                 = "frontend-private-dns-group-${var.environment}-projname-${local.prefix}"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_auth_front.id]
  }
  depends_on = [azurerm_private_endpoint.dp_dbfspe_dfs]
}