# ⚡ Azure Functions Java Demo 🚀

<div align="center">

![Java](https://img.shields.io/badge/Java-11+-ED8B00?style=for-the-badge&logo=java&logoColor=white)
![Azure Functions](https://img.shields.io/badge/Azure%20Functions-0062AD?style=for-the-badge&logo=azure-functions&logoColor=white)
![Maven](https://img.shields.io/badge/Maven-C71A36?style=for-the-badge&logo=apache-maven&logoColor=white)
![Service Bus](https://img.shields.io/badge/Service%20Bus-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)

**A comprehensive demonstration of Azure Functions in Java with order processing capabilities and Infrastructure as Code** 📦

</div>

## 🎯 Purpose

This repository showcases a **production-ready Azure Functions application** built with Java, demonstrating:

- 🔧 **HTTP-triggered serverless functions**
- ✅ **Jakarta Bean Validation** for request validation
- 🚌 **Azure Service Bus integration** for message queuing
- 📋 **Complete order processing workflow**
- 🏗️ **Enterprise-ready architecture patterns**
- ☁️ **Infrastructure as Code** with Terraform
- 🔐 **Managed Identity** for secure, credential-free authentication
- 📊 **Comprehensive monitoring** with Application Insights and Log Analytics

Perfect for developers learning Azure Functions with Java or looking for a solid foundation for serverless order processing systems!

## 🏗️ Architecture Overview

![Architecture Overview](./architecture-diagram.svg)

## 📁 Repository Structure

```
📁 Azure-Functions-Java-Demo/
├── 📄 pom.xml                                    # Maven configuration & dependencies
├── 📄 host.json                                  # Azure Functions runtime configuration
├── 📄 local.settings.json.template               # Template for local development settings
├── 📁 terraform/                                 # Infrastructure as Code
│   ├── 📄 main.tf                                # Main infrastructure configuration
│   ├── 📄 variables.tf                           # Input variables definition
│   ├── 📄 outputs.tf                             # Output values
│   ├── 📄 providers.tf                           # Provider configuration
│   ├── 🔧 deploy.sh                              # Deployment automation script
│   ├── 📖 README.md                              # Infrastructure documentation
│   └── 📁 environments/                          # Environment-specific configurations
│       ├── 📁 dev/                               # Development environment
│       └── 📁 prod/                              # Production environment
├── 📁 src/main/java/com/christopherhouse/functions/
│   ├── ⚡ ReceiveOrder.java                      # Main order processing function (updated for identity auth)
│   ├── 📁 models/                               # Data transfer objects
│   │   ├── 📋 OrderRequest.java                 # Incoming order model with validation
│   │   ├── ✅ OrderConfirmation.java            # Response confirmation model
│   │   ├── 📦 LineItem.java                     # Individual order item model
│   │   └── 🏷️ OrderStatus.java                  # Order status enumeration
│   └── 📁 services/
│       └── ✅ OrderValidation.java              # Jakarta Bean Validation service
└── 📁 target/                                   # Build output (auto-generated)
    └── 📁 azure-functions/                      # Packaged function app
```

## 🚀 Functions & Services

### ⚡ ReceiveOrder Function

The **main HTTP-triggered function** that orchestrates the complete order processing workflow:

**🔧 Functionality:**
- **HTTP Trigger**: Accepts `POST` requests to `/api/ReceiveOrder`
- **JSON Deserialization**: Converts incoming JSON to `OrderRequest` objects
- **Order Validation**: Uses Jakarta Bean Validation for comprehensive data validation
- **Service Bus Integration**: Forwards valid orders to Azure Service Bus queue
- **Response Generation**: Returns `OrderConfirmation` with processing status

**📊 Input/Output:**
```java
// Input: OrderRequest JSON
{
  "customerName": "John Doe",
  "customerEmail": "john.doe@example.com",
  "customerPhone": "555-1234",
  "shippingAddress": "123 Main St",
  "paymentMethod": "Credit Card",
  "orderDate": "2025-01-01",
  "orderStatus": "NEW",
  "orderId": "ORDER-001",
  "customerId": "CUST-001",
  "lineItems": [
    {
      "productId": "PROD-001",
      "productName": "Demo Product",
      "quantity": 2,
      "unitPrice": 29.99
    }
  ]
}

// Output: OrderConfirmation JSON
{
  "orderId": "ORDER-001",
  "customerName": "John Doe",
  "customerEmail": "john.doe@example.com",
  "orderDate": "2025-01-01",
  "orderStatus": "RECEIVED",
  "totalAmount": 59.98
}
```

### 📋 Data Models

#### OrderRequest Model
**Rich domain model** with comprehensive validation:
- ✅ **@NotNull** validations for required fields
- 📧 **@Email** validation for customer email
- 📝 **@NotEmpty** validation for line items
- 🔢 **@Min** validation for quantities
- 💰 **@DecimalMin** validation for prices

#### LineItem Model
**Encapsulates individual order items** with automatic calculations:
- 🧮 **Automatic total calculation**: `getTotalPrice() = quantity * unitPrice`
- ✅ **Built-in validation** for product data integrity

#### OrderConfirmation Model
**Response model** providing order processing confirmation with calculated totals.

### ✅ OrderValidation Service

**Enterprise-grade validation service** using Jakarta Bean Validation:
- 🏭 **Factory Pattern**: Uses `Validation.buildDefaultValidatorFactory()`
- 🔍 **Comprehensive Validation**: Validates all model constraints
- 📊 **Detailed Error Reporting**: Provides specific violation messages
- 🛡️ **Exception Handling**: Graceful handling of validation errors

## 🛠️ Development Workflow

### 🔧 Prerequisites

- ☕ **Java 11+** (OpenJDK recommended)
- 📦 **Maven 3.6+**
- ⚡ **Azure Functions Core Tools v4+**
- 🌐 **Internet connection** (for extension bundles)

### 🏗️ Build Process

```bash
# 1️⃣ Clean build
mvn clean compile          # 🕐 ~60 seconds first run, ~2 seconds cached

# 2️⃣ Package for deployment
mvn package               # 🕐 ~130 seconds first run, ~6 seconds cached

# 3️⃣ Run tests
mvn test                  # 🕐 ~2 seconds (no tests currently)
```

### 🚀 Local Development

```bash
# 🔧 Install Azure Functions Core Tools (if not installed)
npm install -g azure-functions-core-tools@4

# 🎯 Start local Functions runtime
func start --java --prefix target/azure-functions/DemoOrderFunction-1754659291844

# 🌐 Function will be available at:
# POST http://localhost:7071/api/ReceiveOrder
```

### 📋 Manual Testing

Create test file `/tmp/test_order.json`:
```json
{
  "customerName": "Jane Smith",
  "customerEmail": "jane.smith@example.com",
  "customerPhone": "555-9876",
  "shippingAddress": "456 Oak Avenue",
  "paymentMethod": "Credit Card",
  "orderDate": "2025-01-15",
  "orderStatus": "NEW",
  "orderId": "ORDER-002",
  "customerId": "CUST-002",
  "lineItems": [
    {
      "productId": "PROD-002",
      "productName": "Sample Product",
      "quantity": 1,
      "unitPrice": 49.99
    }
  ]
}
```

Test with curl:
```bash
curl -X POST http://localhost:7071/api/ReceiveOrder \
  -H "Content-Type: application/json" \
  -d @/tmp/test_order.json
```

### ⚙️ Configuration

#### Infrastructure Configuration

Infrastructure settings are managed through Terraform variables:

- **Environment-specific**: `terraform/environments/{env}/terraform.tfvars`
- **Backend state**: `terraform/environments/{env}/backend.conf`
- **Customizable settings**: Function App SKU, Service Bus tier, retention periods, security settings

#### Application Configuration

**Production (Identity-based)**:
```json
{
  "ServiceBusConnection__fullyQualifiedNamespace": "namespace.servicebus.windows.net",
  "ServiceBusConnection__credential": "managedidentity",
  "AzureWebJobsStorage__accountName": "storageaccountname",
  "AzureWebJobsStorage__credential": "managedidentity"
}
```

**Local Development (Connection strings)**:
```json
{
  "ServiceBusConnection": "Endpoint=sb://namespace.servicebus.windows.net/;SharedAccessKeyName=key;SharedAccessKey=secret",
  "AzureWebJobsStorage": "DefaultEndpointsProtocol=https;AccountName=account;AccountKey=key;EndpointSuffix=core.windows.net"
}
```

### 🚀 Deployment

### Infrastructure Deployment

The repository includes complete Infrastructure as Code using Terraform:

```bash
# Navigate to infrastructure directory
cd terraform/

# Set up backend storage (one-time setup)
# Follow instructions in terraform/README.md

# Deploy development environment
./deploy.sh dev plan    # Review planned changes
./deploy.sh dev apply   # Deploy infrastructure

Windows / PowerShell alternative:

```powershell
cd terraform
./deploy.ps1 dev plan
./deploy.ps1 dev apply
./deploy.ps1 prod plan
./deploy.ps1 prod apply
```

# Deploy production environment
./deploy.sh prod plan   # Review planned changes
./deploy.sh prod apply  # Deploy infrastructure
PowerShell variant:
```powershell
terraform/deploy.ps1 -Environment dev -Action plan
terraform/deploy.ps1 -Environment dev -Action apply
```
```

**Infrastructure includes:**
- ☁️ **Resource Group** with consistent naming
- 📊 **Log Analytics Workspace** for centralized logging
- 📈 **Application Insights** for performance monitoring
- 🔐 **User-Assigned Managed Identity** for secure authentication
- 💾 **Storage Account** with managed identity integration
- 🚌 **Service Bus Namespace** with topics and subscriptions
- ⚡ **App Service Plan** (Consumption/Premium/Isolated options)
- 🔧 **Function App** with Java 11 runtime and identity-based connections

#### Local Terraform Plan / Apply with Azure CLI (No OIDC)

CI/CD uses OIDC federation by default. Locally you can override this to use your `az login` credentials without touching tracked files.

Steps:

1. Authenticate and (optionally) select subscription:
  ```powershell
  az login
  az account set --subscription <your-subscription-id>   # optional if default is already correct
  ```
2. Create a local override file (gitignored):
  ```powershell
  Copy-Item terraform\local.example.auto.tfvars terraform\local.auto.tfvars
  ```
  Leave `use_oidc = false` in place. Optionally uncomment & set `subscription_id` / `tenant_id` to pin them; otherwise the AzureRM provider will infer from the current CLI context.
3. Run plan / apply (script wraps backend + var files):
  ```powershell
  bash terraform/deploy.sh dev plan    # or prod
  bash terraform/deploy.sh dev apply
  ```
  (Use Git Bash / WSL for `bash`. Alternatively run the Terraform commands directly below.)

Direct Terraform (if you prefer not to use the script):
```powershell
cd terraform
terraform init -backend-config="environments/dev/backend.conf" -reconfigure
terraform plan -var-file="environments/dev/terraform.tfvars" -out="environments/dev/terraform.plan"
terraform apply environments/dev/terraform.plan
```

Cleanup (optional): delete `terraform/local.auto.tfvars` to revert fully to default OIDC behavior.

Notes:
- `local.auto.tfvars` is ignored via `.gitignore`; never commit it.
- CI remains unaffected because the default of `use_oidc = true` (defined in `variables.tf`) is still applied when the local override file is absent.
- You can maintain different local contexts by editing only the override file; no changes to environment tfvars required.

### Application Deployment

After infrastructure is deployed:

```bash
# Package the application
mvn clean package

# Deploy to Azure (requires infrastructure to be deployed first)
mvn azure-functions:deploy

# Or use automated deployment through CI/CD pipelines
```

## 🔍 Key Technologies

| Technology | Version | Purpose |
|------------|---------|---------|
| ☕ **Java** | 11+ | Core runtime |
| ⚡ **Azure Functions** | 3.0.0 | Serverless platform |
| ✅ **Jakarta Validation** | 3.0.2 | Request validation |
| 🔧 **Hibernate Validator** | 7.0.5 | Validation implementation |
| 📋 **Jackson Databind** | 2.14.2 | JSON processing |
| 📦 **Maven** | 3.6+ | Build automation |
| 🧪 **JUnit Jupiter** | 5.4.2 | Testing framework |

## 💡 Features

- ✅ **Enterprise Validation**: Comprehensive request validation using Jakarta Bean Validation
- 🚌 **Message Queuing**: Asynchronous order processing via Service Bus Topics
- 🔄 **Error Handling**: Graceful handling of invalid requests and processing errors
- 📊 **Automatic Calculations**: Built-in order total calculations
- 🏗️ **Scalable Architecture**: Serverless design for automatic scaling
- 🛡️ **Type Safety**: Strong typing with comprehensive data models
- 📋 **Structured Logging**: Built-in logging through Azure Functions runtime
- ☁️ **Infrastructure as Code**: Complete Terraform infrastructure with Azure Verified Modules
- 🔐 **Managed Identity**: Credential-free authentication for all Azure services
- 📈 **Monitoring**: Application Insights and Log Analytics integration
- 🌍 **Multi-Environment**: Separate configurations for dev, test, and production
- 🔧 **Automated Deployment**: Scripts for infrastructure and application deployment

## 🤝 Contributing

1. 🍴 Fork the repository
2. 🌟 Create a feature branch (`git checkout -b feature/amazing-feature`)
3. 💾 Commit your changes (`git commit -m 'Add amazing feature'`)
4. 🚀 Push to the branch (`git push origin feature/amazing-feature`)
5. 🔄 Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**⭐ Don't forget to star this repository if it helped you! ⭐**

Made with ❤️ for the Azure Functions community

</div>