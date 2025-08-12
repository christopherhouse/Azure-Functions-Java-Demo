
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

resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.enable_diagnostic_settings ? 1 : 0
  name                       = var.diagnostic_name
  target_resource_id         = azurerm_storage_account.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category = "StorageRead" }
  enabled_log { category = "StorageWrite" }
  enabled_log { category = "StorageDelete" }
  enabled_log { category = "Service" }
  enabled_log { category = "Delete" }
  enabled_log { category = "Audit" }
  enabled_log { category = "Transaction" }
  enabled_log { category = "Network" }
  enabled_log { category = "FileAccess" }
  enabled_log { category = "FileShare" }
  enabled_log { category = "Table" }
  enabled_log { category = "Queue" }
  enabled_metric { category = "AllMetrics" }
}

resource "azurerm_role_assignment" "rbac" {
  for_each             = { for idx, r in var.rbac_assignments : idx => r }
  scope                = azurerm_storage_account.this.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}
