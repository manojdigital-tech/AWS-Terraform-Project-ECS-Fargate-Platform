// Azure App module: basic resource group + App Service for web app demo.

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    project = var.project
    env     = var.environment
  }
}

resource "azurerm_service_plan" "this" {
  name                = "${var.project}-${var.environment}-plan"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  os_type  = var.app_service_os_type
  sku_name = var.app_service_sku_name

  tags = {
    project = var.project
    env     = var.environment
  }
}

resource "azurerm_linux_web_app" "this" {
  name                = "${var.project}-${var.environment}-webapp"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.this.id

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }

  tags = {
    project = var.project
    env     = var.environment
  }
}


