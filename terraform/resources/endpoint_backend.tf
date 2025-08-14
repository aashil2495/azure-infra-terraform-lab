resource "azurerm_private_endpoint" "dp_dpcp" {
  name                = "pe-backend-${var.environment}-projname-${local.prefix}"
  location            = azurerm_resource_group.rg-data-infra.location
  resource_group_name = azurerm_resource_group.rg-data-infra.name
  subnet_id           = azurerm_subnet.dp_plsubnet.id

  private_service_connection {
    name                           = "pe-backend-serv-conn-${var.environment}-projname-${local.prefix}"
    private_connection_resource_id = azurerm_databricks_workspace.dp_workspace.id
    is_manual_connection           = false
    subresource_names              = ["databricks_ui_api"]
  }

  private_dns_zone_group {
    name                 = "backend-private-dns-group-${var.environment}-projname-${local.prefix}"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdpcp.id]
  }
}