# Define the Azure Key Vault resource
resource "azurerm_key_vault" "standard-secure-kv" {
  name                          = "kv-${var.environment}-projname-${local.prefix}" #Add variable to set keyvault name
  location                      = azurerm_resource_group.rg-data-infra.location
  resource_group_name           = azurerm_resource_group.rg-data-infra.name
  tenant_id                     = local.tenant_id
  purge_protection_enabled      = true
  enable_rbac_authorization     = true 
  public_network_access_enabled = true

  sku_name = "standard"

  soft_delete_retention_days = 7

  lifecycle {
    ignore_changes = [tags]
  }
}






