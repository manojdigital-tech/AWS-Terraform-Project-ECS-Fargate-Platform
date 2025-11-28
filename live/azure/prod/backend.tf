// backend.tf
// Placeholder backend configuration for Azure prod.

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-backend-prod" // TODO
    storage_account_name = "tfstatebackendprod"        // TODO
    container_name       = "tfstate"
    key                  = "infra-project/prod/terraform.tfstate"
  }
}


