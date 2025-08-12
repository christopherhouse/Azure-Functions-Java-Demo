output "app_service_plan_name" {
  description = "The name of the App Service Plan"
  value       = azurerm_service_plan.asp.name
}
output "app_service_plan_id" {
  description = "The resource ID of the App Service Plan"
  value       = azurerm_service_plan.asp.id
}

output "function_app_id" {
  description = "The resource ID of the Function App"
  value       = azurerm_linux_function_app.fa.id
}

output "function_app_identity_principal_id" {
  description = "The principal ID of the Function App system assigned identity"
  value       = azurerm_linux_function_app.fa.identity[0].principal_id
}

output "function_app_name" {
  description = "The name of the Function App"
  value       = azurerm_linux_function_app.fa.name
}