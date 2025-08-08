# Azure Functions Java Demo - Order Processing System

## Overview

This repository contains a Java-based Azure Functions solution that demonstrates order processing capabilities using serverless architecture. The solution includes HTTP-triggered functions for receiving and validating orders, with integration to Azure Service Bus for reliable message processing.

## Architecture

The solution consists of two main Azure Functions:

1. **HttpTriggerJava** - A simple HTTP-triggered function that demonstrates basic request/response handling
2. **ReceiveOrder** - An order processing function that validates incoming orders and forwards them to a Service Bus queue

### Components

```
src/main/java/com/christopherhouse/functions/
├── HttpTriggerJava.java          # Basic HTTP trigger function
├── ReceiveOrder.java             # Order processing function
├── models/
│   ├── OrderRequest.java         # Order request data model
│   ├── OrderConfirmation.java    # Order confirmation response model
│   ├── LineItem.java            # Order line item model
│   └── OrderStatus.java         # Order status enumeration
└── services/
    └── OrderValidation.java      # Order validation service
```

### Technology Stack

- **Java 11** - Runtime environment
- **Azure Functions Runtime 4.x** - Serverless compute platform
- **Maven** - Build and dependency management
- **Jakarta Bean Validation** - Input validation
- **Jackson** - JSON serialization/deserialization
- **Azure Service Bus** - Message queuing service
- **JUnit 5 & Mockito** - Testing framework

## Prerequisites

Before you can run this solution, ensure you have the following installed:

- **Java 11 or later**
- **Maven 3.6+**
- **Azure CLI 2.0+**
- **Azure Functions Core Tools 4.x**
- **Visual Studio Code** (recommended) with Azure Functions extension

### Azure Resources Required

- Azure Function App
- Azure Service Bus Namespace with a queue named `received-orders`
- Azure Storage Account (for Function App storage)

## Local Development Setup

### 1. Clone the Repository

```bash
git clone https://github.com/christopherhouse/Azure-Functions-Java-Demo.git
cd Azure-Functions-Java-Demo
```

### 2. Install Dependencies

```bash
mvn clean install
```

### 3. Configure Local Settings

Create a `local.settings.json` file in the root directory:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "java",
    "serviceBusConnectionString": "Endpoint=sb://your-servicebus-namespace.servicebus.windows.net/;SharedAccessKeyName=your-key-name;SharedAccessKey=your-key-value"
  }
}
```

### 4. Start Azure Storage Emulator

For local development, start the Azure Storage Emulator:

```bash
# Windows
AzureStorageEmulator.exe start

# Or use Azurite (cross-platform)
npm install -g azurite
azurite --silent --location c:\azurite --debug c:\azurite\debug.log
```

### 5. Run Functions Locally

```bash
mvn clean package
mvn azure-functions:run
```

The functions will be available at:
- HttpTriggerJava: `http://localhost:7071/api/HttpTriggerJava`
- ReceiveOrder: `http://localhost:7071/api/ReceiveOrder`

## API Documentation

### HttpTriggerJava Function

**Endpoint:** `GET/POST /api/HttpTriggerJava`

Simple greeting function that accepts a name parameter.

**Request:**
```bash
# Query parameter
curl "http://localhost:7071/api/HttpTriggerJava?name=World"

# Request body
curl -X POST "http://localhost:7071/api/HttpTriggerJava" \
  -H "Content-Type: application/json" \
  -d "Azure Functions"
```

**Response:**
```
Hello, World
```

### ReceiveOrder Function

**Endpoint:** `POST /api/ReceiveOrder`

Processes order requests with validation and forwards valid orders to Service Bus.

**Request Body:**
```json
{
  "customerName": "John Doe",
  "customerEmail": "john.doe@example.com",
  "customerPhone": "+1-555-0123",
  "shippingAddress": "123 Main St, City, State 12345",
  "billingAddress": "123 Main St, City, State 12345",
  "paymentMethod": "Credit Card",
  "orderDate": "2024-01-15T10:30:00Z",
  "orderStatus": "PENDING",
  "orderId": "ORD-001",
  "customerId": "CUST-001",
  "specialInstructions": "Leave at front door",
  "lineItems": [
    {
      "productId": "PROD-001",
      "productName": "Widget",
      "quantity": 2,
      "unitPrice": 19.99,
      "totalPrice": 39.98
    }
  ]
}
```

**Success Response (200):**
```json
{
  "orderId": "ORD-001",
  "customerName": "John Doe",
  "customerEmail": "john.doe@example.com",
  "orderDate": "2024-01-15T10:30:00Z",
  "orderStatus": "RECEIVED",
  "totalAmount": 39.98
}
```

**Validation Error Response (200):**
```json
{
  "orderStatus": "INVALID"
}
```

**Bad Request Response (400):**
```
Invalid order request format.
```

## Deployment

### Using Azure Functions Maven Plugin

1. **Configure Azure Authentication:**
```bash
az login
```

2. **Update Maven Configuration:**
Update the `functionAppName` in `pom.xml`:
```xml
<functionAppName>your-unique-function-app-name</functionAppName>
```

3. **Deploy to Azure:**
```bash
mvn clean package azure-functions:deploy
```

### Manual Deployment via Azure CLI

1. **Create Resource Group:**
```bash
az group create --name java-functions-group --location westus
```

2. **Create Storage Account:**
```bash
az storage account create \
  --name yourstorageaccount \
  --resource-group java-functions-group \
  --location westus \
  --sku Standard_LRS
```

3. **Create Function App:**
```bash
az functionapp create \
  --resource-group java-functions-group \
  --consumption-plan-location westus \
  --runtime java \
  --runtime-version 11 \
  --functions-version 4 \
  --name your-function-app-name \
  --storage-account yourstorageaccount
```

4. **Configure Service Bus Connection:**
```bash
az functionapp config appsettings set \
  --name your-function-app-name \
  --resource-group java-functions-group \
  --settings "serviceBusConnectionString=your-connection-string"
```

5. **Deploy Function Code:**
```bash
mvn clean package azure-functions:deploy
```

## Configuration

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `serviceBusConnectionString` | Azure Service Bus connection string | Yes |
| `AzureWebJobsStorage` | Azure Storage connection string | Yes |
| `FUNCTIONS_WORKER_RUNTIME` | Runtime type (should be `java`) | Yes |

### Function App Settings

Configure these settings in your Azure Function App:

- **Runtime Version:** ~4
- **Java Version:** 11
- **Platform:** 64-bit
- **Always On:** Enabled (for production)

## Testing

### Running Unit Tests

```bash
mvn test
```

### Integration Testing

For integration testing with actual Azure services:

1. Set up test Azure resources
2. Configure test connection strings
3. Run integration tests:

```bash
mvn verify -Dspring.profiles.active=integration
```

### Manual Testing

Test the functions using curl or a REST client:

```bash
# Test basic function
curl "https://your-function-app.azurewebsites.net/api/HttpTriggerJava?name=Test"

# Test order processing
curl -X POST "https://your-function-app.azurewebsites.net/api/ReceiveOrder" \
  -H "Content-Type: application/json" \
  -H "x-functions-key: your-function-key" \
  -d @sample-order.json
```

## Monitoring

### Application Insights

The Function App automatically integrates with Application Insights for:
- Request tracking
- Performance monitoring
- Error logging
- Custom telemetry

### Key Metrics to Monitor

- Function execution count
- Function duration
- Error rate
- Service Bus queue length
- Cold start frequency

## Troubleshooting

### Common Issues

**Function not starting locally:**
- Ensure Java 11 is installed and `JAVA_HOME` is set
- Verify Azure Functions Core Tools is installed
- Check `local.settings.json` configuration

**Service Bus connection errors:**
- Verify the connection string is correct
- Ensure the Service Bus queue `received-orders` exists
- Check network connectivity and firewall settings

**Deployment failures:**
- Verify Azure CLI is authenticated
- Check Function App name is unique
- Ensure resource group exists

**Build failures:**
- Run `mvn clean install` to refresh dependencies
- Check Java version compatibility
- Verify Maven is properly configured

### Logs and Debugging

**Local Development:**
- Function logs appear in the console when running locally
- Use Application Insights for cloud debugging

**Azure Environment:**
- Check Function App logs in the Azure portal
- Use Log Stream for real-time log viewing
- Monitor Application Insights for detailed telemetry

## Contributing

### Development Guidelines

1. Follow the coding standards defined in `.github/copilot-instructions.md`
2. Write unit tests for all new functionality
3. Update documentation for any changes
4. Use meaningful commit messages
5. Create pull requests for all changes

### Code Style

- Use Java naming conventions
- Follow the existing package structure
- Add JavaDoc comments for public methods
- Keep functions focused and single-purpose

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Support

For questions or issues:
1. Check the troubleshooting section above
2. Review existing GitHub issues
3. Create a new issue with detailed information
4. For Azure-specific issues, consult [Azure Functions documentation](https://docs.microsoft.com/en-us/azure/azure-functions/)

## Additional Resources

- [Azure Functions Java Developer Guide](https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference-java)
- [Azure Service Bus Documentation](https://docs.microsoft.com/en-us/azure/service-bus-messaging/)
- [Maven Azure Functions Plugin](https://github.com/microsoft/azure-maven-plugins/wiki/Azure-Functions)
- [Azure Functions Best Practices](https://docs.microsoft.com/en-us/azure/azure-functions/functions-best-practices)