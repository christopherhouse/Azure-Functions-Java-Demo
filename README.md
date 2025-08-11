# ⚡ Azure Functions Java Demo 🚀

<div align="center">

![Java](https://img.shields.io/badge/Java-11+-ED8B00?style=for-the-badge&logo=java&logoColor=white)
![Azure Functions](https://img.shields.io/badge/Azure%20Functions-0062AD?style=for-the-badge&logo=azure-functions&logoColor=white)
![Maven](https://img.shields.io/badge/Maven-C71A36?style=for-the-badge&logo=apache-maven&logoColor=white)
![Service Bus](https://img.shields.io/badge/Service%20Bus-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)

**A comprehensive demonstration of Azure Functions in Java with order processing capabilities** 📦

</div>

## 🎯 Purpose

This repository showcases a **production-ready Azure Functions application** built with Java, demonstrating:

- 🔧 **HTTP-triggered serverless functions**
- ✅ **Jakarta Bean Validation** for request validation
- 🚌 **Azure Service Bus integration** for message queuing
- 📋 **Complete order processing workflow**
- 🏗️ **Enterprise-ready architecture patterns**

Perfect for developers learning Azure Functions with Java or looking for a solid foundation for serverless order processing systems!

## 🏗️ Architecture Overview

```svg
<svg width="800" height="400" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <style>
      .title { font: bold 16px sans-serif; fill: #2563eb; }
      .label { font: 12px sans-serif; fill: #374151; }
      .box { fill: #f8fafc; stroke: #2563eb; stroke-width: 2; rx: 8; }
      .client { fill: #dbeafe; stroke: #3b82f6; stroke-width: 2; rx: 8; }
      .function { fill: #dcfce7; stroke: #22c55e; stroke-width: 2; rx: 8; }
      .service { fill: #fef3c7; stroke: #f59e0b; stroke-width: 2; rx: 8; }
      .queue { fill: #ede9fe; stroke: #8b5cf6; stroke-width: 2; rx: 8; }
      .arrow { stroke: #374151; stroke-width: 2; fill: none; marker-end: url(#arrowhead); }
      .response { stroke: #22c55e; stroke-width: 2; fill: none; marker-end: url(#arrowhead); stroke-dasharray: 5,5; }
    </style>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#374151" />
    </marker>
  </defs>
  
  <!-- Title -->
  <text x="400" y="25" text-anchor="middle" class="title">🏗️ Azure Functions Order Processing Architecture</text>
  
  <!-- Client -->
  <rect x="50" y="60" width="120" height="80" class="client"/>
  <text x="110" y="85" text-anchor="middle" class="label">📱 Client</text>
  <text x="110" y="105" text-anchor="middle" class="label">Application</text>
  <text x="110" y="125" text-anchor="middle" class="label">(HTTP POST)</text>
  
  <!-- Azure Function -->
  <rect x="220" y="60" width="140" height="80" class="function"/>
  <text x="290" y="85" text-anchor="middle" class="label">⚡ ReceiveOrder</text>
  <text x="290" y="105" text-anchor="middle" class="label">Azure Function</text>
  <text x="290" y="125" text-anchor="middle" class="label">(HTTP Trigger)</text>
  
  <!-- Order Validation -->
  <rect x="220" y="180" width="140" height="80" class="service"/>
  <text x="290" y="205" text-anchor="middle" class="label">✅ Order</text>
  <text x="290" y="225" text-anchor="middle" class="label">Validation</text>
  <text x="290" y="245" text-anchor="middle" class="label">Service</text>
  
  <!-- Service Bus -->
  <rect x="420" y="60" width="140" height="80" class="queue"/>
  <text x="490" y="85" text-anchor="middle" class="label">🚌 Azure</text>
  <text x="490" y="105" text-anchor="middle" class="label">Service Bus</text>
  <text x="490" y="125" text-anchor="middle" class="label">Queue</text>
  
  <!-- Response -->
  <rect x="420" y="180" width="140" height="80" class="box"/>
  <text x="490" y="205" text-anchor="middle" class="label">📋 Order</text>
  <text x="490" y="225" text-anchor="middle" class="label">Confirmation</text>
  <text x="490" y="245" text-anchor="middle" class="label">Response</text>
  
  <!-- Arrows -->
  <!-- Client to Function -->
  <line x1="170" y1="100" x2="215" y2="100" class="arrow"/>
  <text x="192" y="95" text-anchor="middle" class="label">1. POST /api/ReceiveOrder</text>
  
  <!-- Function to Validation -->
  <line x1="290" y1="140" x2="290" y2="175" class="arrow"/>
  <text x="320" y="160" class="label">2. Validate</text>
  
  <!-- Function to Service Bus -->
  <line x1="360" y1="100" x2="415" y2="100" class="arrow"/>
  <text x="387" y="95" text-anchor="middle" class="label">3. Queue Order</text>
  
  <!-- Function to Response -->
  <line x1="360" y1="110" x2="415" y2="180" class="arrow"/>
  <text x="387" y="150" text-anchor="middle" class="label">4. Generate</text>
  
  <!-- Response back to Client -->
  <line x1="420" y1="220" x2="170" y2="110" class="response"/>
  <text x="300" y="170" text-anchor="middle" class="label">5. Return Confirmation</text>
  
  <!-- Legend -->
  <text x="50" y="320" class="label">📱 HTTP Client sends order data</text>
  <text x="50" y="340" class="label">⚡ Azure Function processes request</text>
  <text x="50" y="360" class="label">✅ Jakarta validation ensures data quality</text>
  <text x="400" y="320" class="label">🚌 Valid orders queued for processing</text>
  <text x="400" y="340" class="label">📋 Immediate confirmation returned</text>
  <text x="400" y="360" class="label">🔄 Asynchronous order processing</text>
</svg>
```

## 📁 Repository Structure

```
📁 Azure-Functions-Java-Demo/
├── 📄 pom.xml                                    # Maven configuration & dependencies
├── 📄 host.json                                  # Azure Functions runtime configuration
├── 📁 src/main/java/com/christopherhouse/functions/
│   ├── ⚡ ReceiveOrder.java                      # Main order processing function
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

#### Service Bus Connection

Configure `local.settings.json` in the function app directory:
```json
{
  "IsEncrypted": false,
  "Values": {
    "FUNCTIONS_WORKER_RUNTIME": "java",
    "serviceBusConnectionString": "Endpoint=sb://your-namespace.servicebus.windows.net/;SharedAccessKeyName=your-key;SharedAccessKey=your-secret"
  }
}
```

### 🚀 Deployment

```bash
# 🌐 Deploy to Azure
mvn azure-functions:deploy

# 📊 View deployment status
az functionapp show --name DemoOrderFunction-1754659291844 --resource-group java-functions-group
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
- 🚌 **Message Queuing**: Asynchronous order processing via Service Bus
- 🔄 **Error Handling**: Graceful handling of invalid requests and processing errors
- 📊 **Automatic Calculations**: Built-in order total calculations
- 🏗️ **Scalable Architecture**: Serverless design for automatic scaling
- 🛡️ **Type Safety**: Strong typing with comprehensive data models
- 📋 **Structured Logging**: Built-in logging through Azure Functions runtime

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