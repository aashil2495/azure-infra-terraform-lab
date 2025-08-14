terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.0.0"
    }
    
  }
}


provider "azurerm" {
  features {

    databricks_workspace {
      force_delete = true
    }

    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }

    managed_disk {
      expand_without_downtime = true
    }

    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    template_deployment {
      delete_nested_items_during_deletion = true
    }

  }
  subscription_id = var.subscription_id
}