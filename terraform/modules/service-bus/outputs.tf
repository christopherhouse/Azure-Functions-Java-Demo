output "service_bus" {
  description = "The Service Bus namespace resource"
  value       = module.service_bus.resource
}

output "service_bus_id" {
  description = "The resource ID of the Service Bus namespace"
  value       = module.service_bus.resource.id
}

output "service_bus_name" {
  description = "The name of the Service Bus namespace"
  value       = module.service_bus.resource.name
}