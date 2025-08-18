# Log Analytics Workspace for centralized logging
module "log_analytics" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = ">= 0.3.0"

  name                = var.monitoring_config.log_analytics.name
  location            = var.monitoring_config.log_analytics.location
  resource_group_name = var.monitoring_config.log_analytics.resource_group_name
  enable_telemetry    = var.monitoring_config.log_analytics.enable_telemetry

  log_analytics_workspace_retention_in_days = var.monitoring_config.log_analytics.retention_in_days
  log_analytics_workspace_sku               = var.monitoring_config.log_analytics.sku

  log_analytics_workspace_internet_ingestion_enabled = true
  log_analytics_workspace_internet_query_enabled     = true

  tags = var.monitoring_config.log_analytics.tags
}

# Application Insights for Function App monitoring
module "application_insights" {
  source  = "Azure/avm-res-insights-component/azurerm"
  version = ">= 0.2.0"

  name                = var.monitoring_config.application_insights.name
  location            = var.monitoring_config.application_insights.location
  resource_group_name = var.monitoring_config.application_insights.resource_group_name
  enable_telemetry    = var.monitoring_config.application_insights.enable_telemetry

  application_type              = var.monitoring_config.application_insights.application_type
  workspace_id                  = module.log_analytics.resource.id
  retention_in_days             = var.monitoring_config.application_insights.retention_in_days
  disable_ip_masking            = var.monitoring_config.application_insights.disable_ip_masking
  local_authentication_disabled = var.monitoring_config.application_insights.local_authentication_disabled

  tags = var.monitoring_config.application_insights.tags
}