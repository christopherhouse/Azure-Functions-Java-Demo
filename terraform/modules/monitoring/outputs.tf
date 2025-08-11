output "log_analytics" {
  description = "The Log Analytics workspace resource"
  value       = module.log_analytics.resource
}

output "log_analytics_id" {
  description = "The resource ID of the Log Analytics workspace"
  value       = module.log_analytics.resource.id
}

output "application_insights" {
  description = "The Application Insights resource"
  value       = module.application_insights.resource
}

output "application_insights_id" {
  description = "The resource ID of the Application Insights"
  value       = module.application_insights.resource.id
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key of the Application Insights"
  value       = module.application_insights.resource.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "The connection string of the Application Insights"
  value       = module.application_insights.resource.connection_string
  sensitive   = true
}