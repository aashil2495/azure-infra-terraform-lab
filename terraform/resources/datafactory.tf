# Define Azure Data Factory resource
resource "azurerm_data_factory" "dp_adf" {
  name                = "adf-${var.environment}-projname-${local.prefix}"
  location            = azurerm_resource_group.rg-data-infra.location
  resource_group_name = azurerm_resource_group.rg-data-infra.name

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Define Private DNS Zone for Azure Data Factory
resource "azurerm_private_dns_zone" "adf_private_dns_zone" {
  name                = "privatelink.datafactory.azure.net"
  resource_group_name = azurerm_resource_group.rg-data-infra.name
}

# Link Private DNS Zone with existing Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "adf_vnet_link" {
  name                  = "adf-vnetlink-${var.environment}-projname-${local.prefix}"
  resource_group_name   = azurerm_resource_group.rg-data-infra.name
  private_dns_zone_name = azurerm_private_dns_zone.adf_private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.dp_vnet.id
}

# Define Private Endpoint for Azure Data Factory
resource "azurerm_private_endpoint" "adf_private_endpoint" {
  name                = "pe-adf-${var.environment}-projname-${local.prefix}"
  location            = azurerm_resource_group.rg-data-infra.location
  resource_group_name = azurerm_resource_group.rg-data-infra.name
  subnet_id           = azurerm_subnet.dp_plsubnet.id

  private_service_connection {
    name                           = "pe-adf-serv-conn-${var.environment}-projname-${local.prefix}"
    private_connection_resource_id = azurerm_data_factory.dp_adf.id
    is_manual_connection           = false
    subresource_names              = ["dataFactory"]
  }

  private_dns_zone_group {
    name                 = "adf-private-dns-group-${var.environment}-projname-${local.prefix}"
    private_dns_zone_ids = [azurerm_private_dns_zone.adf_private_dns_zone.id]
  }
}
