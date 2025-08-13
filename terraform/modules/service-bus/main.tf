# Service Bus Namespace
resource "azurerm_servicebus_namespace" "sb" {
  name                = var.service_bus_config.name
  location            = var.service_bus_config.location
  resource_group_name = var.service_bus_config.resource_group_name

  sku                           = var.service_bus_config.sku
  capacity                      = var.service_bus_config.sku == "Premium" ? var.service_bus_config.capacity : null
  public_network_access_enabled = var.service_bus_config.public_network_access_enabled
  minimum_tls_version           = var.service_bus_config.minimum_tls_version

  identity {
    type         = "UserAssigned"
    identity_ids = var.service_bus_config.user_assigned_resource_ids
  }

  tags = var.service_bus_config.tags
}

# Service Bus Topics
resource "azurerm_servicebus_topic" "topics" {
  for_each = var.service_bus_config.topics

  name         = each.key
  namespace_id = azurerm_servicebus_namespace.sb.id

  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  default_message_ttl                     = each.value.default_message_ttl
  auto_delete_on_idle                     = each.value.auto_delete_on_idle
  partitioning_enabled                    = each.value.enable_partitioning
  express_enabled                         = each.value.enable_express
  support_ordering                        = each.value.support_ordering
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
}

# Service Bus Subscriptions
resource "azurerm_servicebus_subscription" "subscriptions" {
  for_each = merge([
    for topic_name, topic in var.service_bus_config.topics : {
      for subscription_name, subscription in topic.subscriptions : "${topic_name}.${subscription_name}" => {
        topic_name        = topic_name
        subscription_name = subscription_name
        subscription      = subscription
      }
    }
  ]...)

  name     = each.value.subscription_name
  topic_id = azurerm_servicebus_topic.topics[each.value.topic_name].id

  max_delivery_count                        = each.value.subscription.max_delivery_count
  lock_duration                             = each.value.subscription.lock_duration
  requires_session                          = each.value.subscription.requires_session
  default_message_ttl                       = each.value.subscription.default_message_ttl
  dead_lettering_on_message_expiration      = each.value.subscription.dead_lettering_on_message_expiration
  dead_lettering_on_filter_evaluation_error = each.value.subscription.dead_lettering_on_filter_evaluation_error
  batched_operations_enabled                = each.value.subscription.enable_batched_operations
  auto_delete_on_idle                       = each.value.subscription.auto_delete_on_idle
}

# Diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "sb_diag" {
  count = var.service_bus_config.enable_diagnostic_settings ? 1 : 0

  name                       = "diag-servicebus"
  target_resource_id         = azurerm_servicebus_namespace.sb.id
  log_analytics_workspace_id = var.service_bus_config.log_analytics_workspace_id

  enabled_log {
    category = "OperationalLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}