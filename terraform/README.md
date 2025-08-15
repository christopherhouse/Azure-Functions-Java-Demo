# Infrastructure as Code for Azure Functions Java Demo

This directory contains Terraform infrastructure as code (IaC) for deploying the Azure Functions Java Demo application. The infrastructure follows Azure best practices and uses Azure Verified Modules (AVM) for reliable, consistent deployments.

## 🏗️ Architecture Overview

The infrastructure deploys the following Azure resources:

- **Resource Group**: Container for all resources
- **Log Analytics Workspace**: Centralized logging and monitoring
- **Application Insights**: Application performance monitoring
- **User-Assigned Managed Identity**: Identity for secure resource access
- **Storage Account**: Function App storage with managed identity authentication
- **Service Bus Namespace**: Message queuing with topics and subscriptions
- **App Service Plan**: Hosting plan for Function App (Consumption/Premium/Isolated)
- **Function App**: Java 11 serverless application with identity-based connections

## 📁 Directory Structure

```
terraform/
├── main.tf                    # Main infrastructure configuration
├── variables.tf               # Input variables definition
├── outputs.tf                 # Output values
├── providers.tf               # Provider configuration
├── deploy.sh                  # Deployment script
├── environments/
│   ├── dev/
│   │   ├── terraform.tfvars   # Development environment variables
│   │   └── backend.conf       # Development backend configuration
│   └── prod/
│       ├── terraform.tfvars   # Production environment variables
│       └── backend.conf       # Production backend configuration
└── README.md                  # This file
```

## 🚀 Quick Start

### Prerequisites

1. **Azure CLI**: Install and login
   ```bash
   az login
   ```

2. **Terraform**: Install Terraform >= 1.9
   ```bash
   # Check version
   terraform version
   ```

3. **Permissions**: Ensure you have Contributor access to the Azure subscription

> **Note**: Backend storage (storage account and container) is automatically created by the deployment scripts. No manual setup required!

### Deploy Development Environment

```bash
# Navigate to terraform directory
cd terraform

# Plan deployment
./deploy.sh dev plan

# Apply deployment
./deploy.sh dev apply
```

### Deploy Production Environment

```bash
# Plan deployment
./deploy.sh prod plan

# Apply deployment
./deploy.sh prod apply
```

## ⚙️ Configuration

### Environment Variables

Each environment has its own `terraform.tfvars` file with environment-specific configuration:

#### Key Configuration Options

| Variable | Description | Dev Default | Prod Default |
|----------|-------------|-------------|--------------|
| `environment` | Environment name | `dev` | `prod` |
| `function_app_sku` | Function App SKU | `Y1` (Consumption) | `EP1` (Premium) |
| `service_bus_sku` | Service Bus SKU | `Standard` | `Premium` |
| `storage_account_replication_type` | Storage replication | `LRS` | `GRS` |
| `log_analytics_retention_days` | Log retention | `30` | `90` |
| `java_version` | Java runtime version | `11` | `11` |

#### Service Bus Topics Configuration

The infrastructure creates Service Bus topics and subscriptions based on the `service_bus_topics` variable:

```hcl
service_bus_topics = {
  received-orders = {
    max_size_in_megabytes        = 1024
    requires_duplicate_detection = false
    enable_partitioning          = true
    
    subscriptions = {
      processing = {
        max_delivery_count                   = 10
        dead_lettering_on_message_expiration = true
      }
    }
  }
}
```

### Backend Configuration

Terraform state is stored in Azure Storage. Each environment has its own backend configuration:

```hcl
# environments/dev/backend.conf
resource_group_name  = "rg-terraform-state-dev"
storage_account_name = "stterraformstatedev001"
container_name       = "terraform-state"
key                  = "azure-functions-java-demo/dev/terraform.tfstate"
```

#### Automated Backend Storage Setup

The deployment scripts automatically create the required backend storage infrastructure:

- **Resource Group**: For storing Terraform state resources
- **Storage Account**: Secure storage with proper configuration
- **Container**: Blob container for state files

The bootstrap process runs automatically when you use the deployment scripts. If you need to run it manually:

```bash
# Bootstrap backend storage for specific environment
./bootstrap-backend.sh dev    # For development environment
./bootstrap-backend.sh prod   # For production environment
```

The bootstrap script is **idempotent** - it's safe to run multiple times and will only create resources that don't already exist.

## 🔐 Security Features

### Managed Identity Integration

The infrastructure implements identity-based authentication:

- **User-Assigned Managed Identity**: Shared identity for all resources
- **System-Assigned Identity**: Per-resource identity for Function App
- **RBAC Assignments**: Least-privilege access to Service Bus and Storage

### Service Bus Authentication

The Function App connects to Service Bus using managed identity:

```java
// Connection string format in Function App settings
ServiceBusConnection__fullyQualifiedNamespace = "namespace.servicebus.windows.net"
ServiceBusConnection__credential = "managedidentity"
ServiceBusConnection__clientId = "managed-identity-client-id"
```

### Storage Account Authentication

Function App storage uses managed identity instead of connection strings:

```java
// Storage account settings (uses system-assigned identity)
AzureWebJobsStorage__accountName = "storageaccountname"
AzureWebJobsStorage__credential = "managedidentity"
// Note: No AzureWebJobsStorage__clientId - defaults to system-assigned identity
```

## 📊 Monitoring and Diagnostics

### Comprehensive Logging

All resources send diagnostic logs to Log Analytics:

- **Function App**: Application logs, HTTP logs, performance metrics
- **Service Bus**: Operational logs, message metrics
- **Storage Account**: Access logs, performance metrics

### Application Insights Integration

- **Performance Monitoring**: Request/response times, dependencies
- **Error Tracking**: Exceptions and failed requests
- **Custom Metrics**: Business metrics from Function App

### Log Analytics Queries

Access logs through Azure portal or use KQL queries:

```kql
// Function App errors
FunctionAppLogs
| where Level == "Error"
| project TimeGenerated, Message, Exception

// Service Bus message metrics
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.SERVICEBUS"
| where Category == "OperationalLogs"
```

## 🔄 CI/CD Integration

### GitHub Actions

Example workflow for automated deployment:

```yaml
name: Deploy Infrastructure

on:
  push:
    branches: [main]
    paths: ['terraform/**']

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.9.0
          
      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
          
      - name: Deploy Infrastructure
        run: |
          cd terraform
          ./deploy.sh dev apply
```

### Azure DevOps

Example pipeline for Azure DevOps:

```yaml
trigger:
  paths:
    include:
      - terraform/*

pool:
  vmImage: 'ubuntu-latest'

steps:
- task: TerraformInstaller@1
  inputs:
    terraformVersion: '1.9.0'

- task: AzureCLI@2
  inputs:
    azureSubscription: 'Azure-Connection'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      cd terraform
      ./deploy.sh dev apply
```

## 🛠️ Customization

### Adding New Environments

1. Create new directory: `environments/staging/`
2. Copy and modify `terraform.tfvars` and `backend.conf`
3. Update backend storage account configuration
4. Deploy using: `./deploy.sh staging apply`

### Adding Resources

To add new Azure resources:

1. Add variables to `variables.tf`
2. Add resource configuration to `main.tf`
3. Add outputs to `outputs.tf`
4. Update environment-specific tfvars files

### Scaling Configuration

#### Consumption Plan (Y1)
- Automatic scaling (0-200 instances)
- Pay-per-execution model
- 5-minute timeout limit
- No always-on support

#### Premium Plan (EP1/EP2/EP3)
- Pre-warmed instances
- Unlimited execution duration
- Always-on support
- VNet integration support

#### Isolated Plan (I1v2/I2v2/I3v2)
- Dedicated compute environment
- Maximum scaling capabilities
- Network isolation
- Highest performance tier

## 📋 Outputs

After deployment, the following outputs are available:

```bash
# View all outputs
terraform output

# View specific output
terraform output function_app_name
terraform output service_bus_namespace_name
```

### Key Outputs

- `function_app_name`: Name of the deployed Function App
- `function_app_default_hostname`: Function App URL
- `service_bus_namespace_name`: Service Bus namespace
- `application_insights_instrumentation_key`: AI instrumentation key
- `user_assigned_identity_client_id`: Managed identity client ID

## 🧪 Testing

### Infrastructure Testing

Validate infrastructure before deployment:

```bash
# Validate Terraform configuration
terraform validate

# Check formatting
terraform fmt -check

# Security scanning (if tfsec is installed)
tfsec .
```

### Post-Deployment Testing

Verify deployed resources:

```bash
# Check Function App status
az functionapp show --name $(terraform output -raw function_app_name) --resource-group $(terraform output -raw resource_group_name)

# Test Service Bus connectivity
az servicebus namespace show --name $(terraform output -raw service_bus_namespace_name) --resource-group $(terraform output -raw resource_group_name)
```

## 🚨 Troubleshooting

### Common Issues

1. **Backend initialization fails**
   - Verify storage account exists and you have access
   - Check backend.conf file configuration

2. **RBAC assignment errors**
   - Ensure you have sufficient permissions
   - Wait for RBAC propagation (up to 5 minutes)

3. **Function App deployment fails**
   - Check App Service Plan SKU compatibility
   - Verify storage account accessibility

4. **Service Bus connection issues**
   - Verify managed identity RBAC assignments
   - Check Service Bus namespace accessibility

### Debug Commands

```bash
# Check Terraform state
terraform state list

# Show specific resource state
terraform state show azurerm_linux_function_app.main

# Import existing resource
terraform import azurerm_resource_group.main /subscriptions/{id}/resourceGroups/{name}

# Enable detailed logging
export TF_LOG=DEBUG
terraform apply
```

## 📞 Support

For issues and questions:

1. Check the [troubleshooting section](#-troubleshooting)
2. Review Azure documentation for specific resources
3. Check Terraform AzureRM provider documentation
4. Open an issue in the repository

## 📚 Additional Resources

- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [Azure Functions Documentation](https://docs.microsoft.com/en-us/azure/azure-functions/)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Service Bus Documentation](https://docs.microsoft.com/en-us/azure/service-bus-messaging/)
- [Azure Storage Documentation](https://docs.microsoft.com/en-us/azure/storage/)