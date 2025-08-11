variable "service_bus_config" {
  description = "Configuration for the Service Bus namespace"
  type = object({
    name                          = string
    location                      = string
    resource_group_name           = string
    enable_telemetry              = bool
    sku                           = string
    capacity                      = optional(number)
    public_network_access_enabled = bool
    minimum_tls_version           = string

    # Managed identity configuration
    user_assigned_resource_ids = list(string)

    # Topics configuration
    topics = map(object({
      max_size_in_megabytes                   = optional(number, 1024)
      requires_duplicate_detection            = optional(bool, false)
      default_message_ttl                     = optional(string, "P14D")
      auto_delete_on_idle                     = optional(string, "P10675199DT2H48M5.4775807S")
      enable_partitioning                     = optional(bool, true)
      enable_express                          = optional(bool, false)
      support_ordering                        = optional(bool, false)
      duplicate_detection_history_time_window = optional(string, "PT10M")

      subscriptions = optional(map(object({
        max_delivery_count                        = optional(number, 10)
        lock_duration                             = optional(string, "PT1M")
        requires_session                          = optional(bool, false)
        default_message_ttl                       = optional(string, "P14D")
        dead_lettering_on_message_expiration      = optional(bool, false)
        dead_lettering_on_filter_evaluation_error = optional(bool, true)
        enable_batched_operations                 = optional(bool, true)
        auto_delete_on_idle                       = optional(string, "P10675199DT2H48M5.4775807S")
      })), {})
    }))

    # Diagnostic settings
    enable_diagnostic_settings = bool
    log_analytics_workspace_id = string

    tags = map(string)
  })
}