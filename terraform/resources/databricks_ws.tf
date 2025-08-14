resource "azurerm_databricks_workspace" "dp_workspace" {
  name                                  = "ws-${var.environment}-projname-${local.prefix}"
  resource_group_name                   = azurerm_resource_group.rg-data-infra.name
  location                              = azurerm_resource_group.rg-data-infra.location
  sku                                   = "premium"
  managed_resource_group_name           = "rg-managed-ws-${var.environment}-projname-${local.prefix}"
  public_network_access_enabled         = true
  network_security_group_rules_required = "NoAzureDatabricksRules"
  customer_managed_key_enabled          = true
  default_storage_firewall_enabled = true
  access_connector_id = azurerm_databricks_access_connector.dp_access_connector.id
  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = azurerm_virtual_network.dp_vnet.id
    private_subnet_name                                  = azurerm_subnet.dp_private.name
    public_subnet_name                                   = azurerm_subnet.dp_public.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.dp_public.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.dp_private.id
    storage_account_name                                 = local.dbfsname
  }
  depends_on = [
    azurerm_subnet_network_security_group_association.dp_public,
    azurerm_subnet_network_security_group_association.dp_private
  ]
}


resource "azurerm_databricks_access_connector" "dp_access_connector" {
  name                = "access-connector-ws-${var.environment}-projname-${local.prefix}"
  resource_group_name = azurerm_resource_group.rg-data-infra.name
  location            = azurerm_resource_group.rg-data-infra.location

  identity {
    type = "SystemAssigned"
  }
}

