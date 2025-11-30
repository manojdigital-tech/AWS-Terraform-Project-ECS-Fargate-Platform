output "resource_group_name" {
  description = "Name of the resource group containing the app."
  value       = azurerm_resource_group.this.name
}

output "app_service_plan_id" {
  description = "ID of the App Service plan."
  value       = azurerm_service_plan.this.id
}

output "web_app_name" {
  description = "Name of the Azure Web App."
  value       = azurerm_linux_web_app.this.name
}

output "web_app_default_hostname" {
  description = "Default hostname (URL) of the Azure Web App."
  value       = azurerm_linux_web_app.this.default_hostname
}


