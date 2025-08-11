output "app_service_plan" {
  description = "The App Service Plan resource"
  value       = module.app_service_plan
}

output "app_service_plan_id" {
  description = "The resource ID of the App Service Plan"
  value       = module.app_service_plan.resource_id
}

output "function_app" {
  description = "The Function App resource"
  value       = module.function_app
}

output "function_app_id" {
  description = "The resource ID of the Function App"
  value       = module.function_app.resource_id
}

output "function_app_identity_principal_id" {
  description = "The principal ID of the Function App system assigned identity"
  value       = module.function_app.identity_principal_id
}

output "function_app_name" {
  description = "The name of the Function App"
  value       = module.function_app.name
}