variable "user_assigned_resource_ids" {
  description = "List of user-assigned managed identity resource IDs."
  type        = list(string)
  default     = []
}
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for storage account."
  type        = bool
  default     = true
}
variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "account_tier" { type = string }
variable "account_replication_type" { type = string }
variable "min_tls_version" { type = string }
variable "account_kind" { type = string }
variable "https_traffic_only_enabled" { type = bool }
variable "public_network_access_enabled" { type = bool }
variable "shared_access_key_enabled" { type = bool }
variable "tags" { type = map(string) }

variable "network_rules" {
  type = object({
    default_action = string
    bypass         = list(string)
    ip_rules       = list(string)
  })
  default = null
}

variable "diagnostic_name" { type = string }
variable "log_analytics_workspace_id" { type = string }

variable "rbac_assignments" {
  description = "List of RBAC assignments to apply to the storage account. Each object must have principal_id and role_definition_name."
  type = list(object({
    principal_id         = string
    role_definition_name = string
  }))
  default = []
}
