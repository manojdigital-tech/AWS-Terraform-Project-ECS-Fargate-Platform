// main.tf
// Placeholder root configuration for Azure dev environment.
// No resources are currently defined. This file exists to mirror the
// live/aws/dev structure and can be filled in when Azure support is added.

terraform {
  required_version = ">= 1.5.0"
}

module "app" {
  source = "../../../modules/azure_app"

  project             = var.project
  environment         = var.environment
  location            = var.location
  resource_group_name = "rg-${var.project}-${var.environment}"
}

