# Resource Names Output
# Provides consistent naming for all Azure resources used in the infrastructure

# Standard resource names using Azure naming module patterns
output "log_analytics_workspace" {
  description = "Log Analytics Workspace name"
  value       = module.azure_naming.log_analytics_workspace.name
}

output "application_insights" {
  description = "Application Insights name"
  value       = module.azure_naming.application_insights.name
}

output "user_assigned_identity" {
  description = "User Assigned Identity name"
  value       = module.azure_naming.user_assigned_identity.name
}

output "servicebus_namespace" {
  description = "Service Bus Namespace name"
  value       = module.azure_naming.servicebus_namespace.name
}

output "app_service_plan" {
  description = "App Service Plan name"
  value       = module.azure_naming.app_service_plan.name
}

output "function_app" {
  description = "Function App name"
  value       = module.azure_naming.function_app.name
}

# Storage account with special handling for naming constraints
output "storage_account" {
  description = "Storage Account name (unique, lowercase, no hyphens)"
  value       = local.storage_name
}

# Diagnostic setting names
output "diagnostic_names" {
  description = "Standardized diagnostic setting names"
  value = {
    storage_account  = "diag-${local.base_name}-storage"
    function_app     = "diag-${local.base_name}-function"
    service_bus      = "diag-${local.base_name}-servicebus"
    log_analytics    = "diag-${local.base_name}-loganalytics"
    file_service     = "diag-${local.base_name}-fileservice"
  }
}

# Base naming components for reference
output "base_name" {
  description = "Base name used for resource naming"
  value       = local.base_name
}

output "unique_suffix" {
  description = "Unique suffix for globally unique resources"
  value       = local.unique_suffix
}