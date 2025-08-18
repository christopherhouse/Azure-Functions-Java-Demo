output "storage_account_id" {
  value = azurerm_storage_account.this.id
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "primary_access_key" {
  description = "Primary access key - only available when shared_access_key_enabled = true"
  value       = var.shared_access_key_enabled ? azurerm_storage_account.this.primary_access_key : null
  sensitive   = true
}

output "resource" {
  value = azurerm_storage_account.this
}
