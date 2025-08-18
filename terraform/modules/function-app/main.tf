resource "azurerm_service_plan" "asp" {
  name                = var.function_app_config.app_service_plan.name
  location            = var.function_app_config.app_service_plan.location
  resource_group_name = var.function_app_config.app_service_plan.resource_group_name
  os_type             = var.function_app_config.app_service_plan.os_type
  sku_name            = var.function_app_config.app_service_plan.sku_name
  tags                = var.function_app_config.app_service_plan.tags
}

resource "azurerm_windows_function_app" "fa" {
  name                = var.function_app_config.function_app.name
  location            = var.function_app_config.function_app.location
  resource_group_name = var.function_app_config.function_app.resource_group_name
  service_plan_id     = azurerm_service_plan.asp.id

  https_only                                     = var.function_app_config.function_app.https_only
  public_network_access_enabled                  = var.function_app_config.function_app.public_network_access_enabled
  ftp_publish_basic_authentication_enabled       = var.function_app_config.function_app.ftp_publish_basic_authentication_enabled
  webdeploy_publish_basic_authentication_enabled = var.function_app_config.function_app.webdeploy_publish_basic_authentication_enabled

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = var.function_app_config.function_app.user_assigned_resource_ids
  }

  storage_account_name = var.function_app_config.function_app.storage_account_name

  # Always use managed identity for storage (no access key)
  storage_account_access_key = null

  site_config {
    application_stack {
      java_version = var.function_app_config.function_app.site_config.java_version
    }
  }

  app_settings = var.function_app_config.function_app.app_settings
  tags         = var.function_app_config.function_app.tags
}

resource "azurerm_monitor_diagnostic_setting" "fa_diag" {
  count                      = var.function_app_config.function_app.enable_diagnostic_settings ? 1 : 0
  name                       = "diag-functionapp"
  target_resource_id         = azurerm_windows_function_app.fa.id
  log_analytics_workspace_id = var.function_app_config.function_app.log_analytics_workspace_id
  enabled_log {
    category = "FunctionAppLogs"
  }
  enabled_log {
    category = "AppServiceAuthenticationLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
