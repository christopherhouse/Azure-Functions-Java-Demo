
resource "azurerm_storage_account" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_tier                  = var.account_tier
  account_replication_type      = var.account_replication_type
  min_tls_version               = var.min_tls_version
  account_kind                  = var.account_kind
  public_network_access_enabled = var.public_network_access_enabled
  shared_access_key_enabled     = var.shared_access_key_enabled
  tags                         = var.tags

  dynamic "identity" {
    for_each = length(var.user_assigned_resource_ids) > 0 ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = var.user_assigned_resource_ids
    }
  }

  dynamic "network_rules" {
    for_each = var.network_rules != null ? [var.network_rules] : []
    content {
      default_action = network_rules.value.default_action
      bypass         = network_rules.value.bypass
      ip_rules       = network_rules.value.ip_rules
    }
  }

}

# Diagnostic setting for the file service (Azure Files)
resource "azurerm_monitor_diagnostic_setting" "file_service" {
  count                      = var.enable_diagnostic_settings ? 1 : 0
  name                       = "diag-fileservice"
  # File service resource ID: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Storage/storageAccounts/{accountName}/fileServices/default
  target_resource_id         = "${azurerm_storage_account.this.id}/fileServices/default"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
  enabled_log {
    category_group = "audit"
  }

  enabled_metric { category = "Transaction" }
}

# Diagnostic setting for the blob service (Azure Blob)
resource "azurerm_monitor_diagnostic_setting" "blob_service" {
  count                      = var.enable_diagnostic_settings ? 1 : 0
  name                       = "diag-blobservice"
  target_resource_id         = "${azurerm_storage_account.this.id}/blobServices/default"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
  enabled_log {
    category_group = "audit"
  }

  enabled_metric { category = "Transaction" }
}

# Diagnostic setting for the queue service (Azure Queue)
resource "azurerm_monitor_diagnostic_setting" "queue_service" {
  count                      = var.enable_diagnostic_settings ? 1 : 0
  name                       = "diag-queueservice"
  target_resource_id         = "${azurerm_storage_account.this.id}/queueServices/default"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
  enabled_log {
    category_group = "audit"
  }

  enabled_metric { category = "Transaction" }
}

# Diagnostic setting for the table service (Azure Table)
resource "azurerm_monitor_diagnostic_setting" "table_service" {
  count                      = var.enable_diagnostic_settings ? 1 : 0
  name                       = "diag-tableservice"
  target_resource_id         = "${azurerm_storage_account.this.id}/tableServices/default"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
  enabled_log {
    category_group = "audit"
  }

  enabled_metric { category = "Transaction" }
}

resource "azurerm_role_assignment" "rbac" {
  for_each             = { for idx, r in var.rbac_assignments : idx => r }
  scope                = azurerm_storage_account.this.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}
