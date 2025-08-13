# Terraform Modules

This directory contains the Terraform modules for the Azure Functions Java Demo infrastructure. The modules follow Terraform best practices for organization and reusability.

## Module Structure

The infrastructure is organized into the following modules:

### identity
**Purpose**: Manages the user-assigned managed identity for the Function App.
**Resources**: 
- User-assigned managed identity

**Input**: Complex object containing identity configuration including name, location, resource group, and tags.

### monitoring
**Purpose**: Manages monitoring and observability resources.
**Resources**:
- Log Analytics workspace
- Application Insights

**Input**: Complex object containing monitoring configuration including retention settings and Application Insights type.

### storage
**Purpose**: Manages the storage account for the Function App.
**Resources**:
- Storage account with managed identity access
- Network rules and diagnostic settings

**Input**: Complex object containing storage configuration including account tier, replication type, and security settings.

### service-bus
**Purpose**: Manages Service Bus namespace and messaging infrastructure.
**Resources**:
- Service Bus namespace
- Topics and subscriptions
- Diagnostic settings

**Input**: Complex object containing Service Bus configuration including SKU, topics, and subscription settings.

### function-app
**Purpose**: Manages the Function App and its hosting infrastructure.
**Resources**:
- App Service Plan (Windows)
- Function App with Java runtime (Windows)
- Application settings and configuration

**Input**: Complex object containing Function App configuration including SKU, runtime settings, and application configuration.

## Design Principles

1. **Complex Object Parameters**: Each module accepts a single complex object parameter that encapsulates all configuration for that module.

2. **Flat Module Structure**: Modules are organized in a single level to avoid deep nesting and circular dependencies.

3. **Clear Separation of Concerns**: Each module handles a specific aspect of the infrastructure:
   - Identity: Authentication and authorization
   - Monitoring: Observability and logging
   - Storage: Data persistence
   - Service Bus: Messaging and queuing
   - Function App: Compute and application hosting

4. **Dependency Management**: Dependencies between modules are managed in the root `main.tf` file using explicit `depends_on` declarations.

5. **RBAC Centralization**: Role-based access control assignments are handled in the root module to avoid circular dependencies.

## Usage

Each module is called from the root `main.tf` with a complex object parameter:

```hcl
module "monitoring" {
  source = "./modules/monitoring"
  
  monitoring_config = {
    log_analytics = {
      # Log Analytics configuration
    }
    application_insights = {
      # Application Insights configuration  
    }
  }
}
```

The complex objects are built dynamically in `main.tf` using:
- Values from `terraform.tfvars` files
- References to the Azure naming module
- References to other modules' outputs

## Benefits

1. **Maintainability**: Clear separation of concerns makes it easier to understand and modify specific parts of the infrastructure.

2. **Reusability**: Modules can be reused across different environments with different configurations.

3. **Testability**: Each module can be tested independently.

4. **Best Practices**: Follows HashiCorp's recommended patterns for Terraform module organization.

5. **Configuration Management**: Complex object parameters provide a clean interface while still allowing for detailed configuration.

## Environment Configuration

Environment-specific configurations are stored in `environments/` directory:
- `environments/dev/terraform.tfvars` - Development environment
- `environments/prod/terraform.tfvars` - Production environment

Each environment defines the complex objects that are passed to the modules, allowing for environment-specific customization while maintaining consistency.