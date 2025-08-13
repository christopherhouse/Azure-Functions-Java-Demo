output "service_bus" {
  description = "The Service Bus namespace resource"
  value       = azurerm_servicebus_namespace.sb
}

output "service_bus_id" {
  description = "The resource ID of the Service Bus namespace"
  value       = azurerm_servicebus_namespace.sb.id
}

output "service_bus_name" {
  description = "The name of the Service Bus namespace"
  value       = azurerm_servicebus_namespace.sb.name
}