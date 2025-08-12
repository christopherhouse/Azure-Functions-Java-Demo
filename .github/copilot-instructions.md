# Azure Functions Java Demo

Azure Functions Java Demo is a Maven-based Java 11 application demonstrating Azure Functions with HTTP triggers and Service Bus integration. It includes order processing functionality with validation and JSON serialization, along with complete Infrastructure as Code (IaC) using Terraform.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Agent Tools
- context7:
  - Use this MCP server to find up to date documentation on common development tools, libraries and frameworks.
  - When planning changes, review current documentation via this tool to ensure changes made are following current approaches and best practices
  - When in doubt,check context7 to see if there is guidance on the topic at hand.
  - Example subjects where context7 can help that are relevant to this repository:
    - Azure
    - Azure Functions
    - Azure Functions for Java
    - Terraform
    - azurerm for Terraform
    - azapi for Terraform
    - GitHub Actions
    - Java
    - Unit testing
    - Secure development practices
    - DevOps
    - DevSecOps
    - GitHub

### Application Development

- Bootstrap, build, and test the repository:
  - Ensure Java 11+ is installed: `java -version` (requires OpenJDK 11 or later)
  - Ensure Maven 3.6+ is installed: `mvn -version`
  - `mvn clean compile` -- takes 60 seconds first run, 2 seconds cached. NEVER CANCEL. Set timeout to 120+ seconds.
  - `mvn package` -- takes 130 seconds first run, 6 seconds cached. NEVER CANCEL. Set timeout to 180+ seconds.
- Test the application:
  - `mvn test` -- takes 2 seconds (no tests currently exist). Set timeout to 30+ seconds.
  - Manually validate core functionality: Compile and run business logic tests as shown in validation section below.
- Run the Azure Functions locally:
  - Install Azure Functions Core Tools v4: Follow Microsoft installation guide or use package manager
  - Configure `local.settings.json` using the template provided
  - `func start --java --prefix target/azure-functions/DemoOrderFunction-1754659291844` -- requires internet connection for extension bundles
  - **NETWORK REQUIREMENT**: Local execution requires internet access to download Azure Functions extension bundles from cdn.functions.azure.com
- Code quality checks:
  - `mvn checkstyle:check` -- validates code style. **WARNING**: Currently fails with 289+ violations using default Sun checks ruleset. Use for reference only.

### Infrastructure Development

- Infrastructure as Code with Terraform:
  - Prerequisites: Azure CLI logged in (`az login`), Terraform 1.9+, appropriate Azure permissions
  - Navigate to `terraform/` directory for all infrastructure operations
  - Validate configuration: `./validate.sh` -- comprehensive validation of Terraform configuration
  - Create backend storage: Follow instructions in `terraform/README.md` for setting up state storage
  - Plan deployment: `./deploy.sh dev plan` (development) or `./deploy.sh prod plan` (production)
  - Apply deployment: `./deploy.sh dev apply` or `./deploy.sh prod apply`
  - Destroy resources: `./deploy.sh dev destroy` or `./deploy.sh prod destroy`
  - **IMPORTANT**: Always plan before applying changes to production
- Infrastructure validation:
  - `terraform validate` -- validates configuration syntax
  - `terraform fmt -check` -- checks formatting
  - `./validate.sh` -- comprehensive validation script
  - Review plan output before applying changes

## Validation

Always manually validate any new code by running business logic tests after making changes.

### Manual Business Logic Validation

Create a test file in `/tmp/test_functions.java` with the following content and run it after any changes:

```java
import com.christopherhouse.functions.models.*;
import com.christopherhouse.functions.services.OrderValidation;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.Arrays;

class TestFunctions {
    public static void main(String[] args) {
        try {
            // Test order validation with valid order
            OrderRequest validOrder = new OrderRequest();
            validOrder.setCustomerName("John Doe");
            validOrder.setCustomerEmail("john.doe@example.com");
            validOrder.setCustomerPhone("555-1234");
            validOrder.setShippingAddress("123 Main St");
            validOrder.setPaymentMethod("Credit Card");
            validOrder.setOrderDate("2025-01-01");
            validOrder.setOrderStatus("NEW");
            validOrder.setOrderId("ORDER-001");
            validOrder.setCustomerId("CUST-001");
            
            LineItem item = new LineItem("PROD-001", "Test Product", 2, 10.50);
            validOrder.setLineItems(Arrays.asList(item));
            
            boolean isValid = OrderValidation.isValidOrder(validOrder);
            System.out.println("Valid order validation result: " + isValid);
            
            // Test JSON serialization
            ObjectMapper mapper = new ObjectMapper();
            String jsonOrder = mapper.writeValueAsString(validOrder);
            System.out.println("JSON serialization successful: " + (jsonOrder.length() > 0));
            
            // Test deserialization with a simpler JSON without calculated fields
            String simpleJson = "{\"customerName\":\"John Doe\",\"customerEmail\":\"john.doe@example.com\",\"customerPhone\":\"555-1234\",\"shippingAddress\":\"123 Main St\",\"paymentMethod\":\"Credit Card\",\"orderDate\":\"2025-01-01\",\"orderStatus\":\"NEW\",\"orderId\":\"ORDER-001\",\"customerId\":\"CUST-001\",\"lineItems\":[{\"productId\":\"PROD-001\",\"productName\":\"Test Product\",\"quantity\":2,\"unitPrice\":10.5}]}";
            OrderRequest deserializedOrder = mapper.readValue(simpleJson, OrderRequest.class);
            System.out.println("JSON deserialization successful: " + (deserializedOrder.getCustomerName() != null));
            
            // Test line item total calculation
            double expectedTotal = 21.0; // 2 * 10.50
            double actualTotal = item.getTotalPrice();
            System.out.println("Line item total calculation correct: " + (expectedTotal == actualTotal));
            
            System.out.println("\nAll tests passed successfully!");
        } catch (Exception e) {
            System.err.println("Test failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```

Run the validation with:
```bash
javac -cp "target/classes:$(mvn -q dependency:build-classpath -Dmdep.outputFile=/dev/stdout)" /tmp/test_functions.java -d /tmp/
java -cp "/tmp:target/classes:$(mvn -q dependency:build-classpath -Dmdep.outputFile=/dev/stdout)" TestFunctions
```

### HTTP Function Testing

Since local runtime requires internet connectivity, test HTTP functions by:
1. Deploy to Azure Functions (requires Azure subscription)
2. Use tools like Postman or curl against deployed endpoints
3. Test individual business logic components as shown above

## Common Tasks

### Repository Structure
```
.
├── pom.xml                           # Maven build configuration
├── host.json                         # Azure Functions host configuration  
├── local.settings.json.template      # Template for local development settings
├── terraform/                        # Infrastructure as Code
│   ├── main.tf                       # Main infrastructure configuration
│   ├── variables.tf                  # Input variables
│   ├── outputs.tf                    # Output values
│   ├── providers.tf                  # Provider configuration
│   ├── deploy.sh                     # Deployment script
│   ├── README.md                     # Infrastructure documentation
│   └── environments/                 # Environment-specific configurations
│       ├── dev/                      # Development environment
│       │   ├── terraform.tfvars      # Dev variables
│       │   └── backend.conf          # Dev backend config
│       └── prod/                     # Production environment
│           ├── terraform.tfvars      # Prod variables
│           └── backend.conf          # Prod backend config
├── src/main/java/com/christopherhouse/functions/
│   ├── ReceiveOrder.java             # Order processing HTTP trigger with Service Bus output (updated for identity-based auth)
│   ├── models/                       # Data models
│   │   ├── OrderRequest.java         # Order request model with validation
│   │   ├── OrderConfirmation.java    # Order confirmation response model
│   │   ├── LineItem.java             # Line item model with calculation
│   │   └── OrderStatus.java          # Order status enumeration
│   └── services/
│       └── OrderValidation.java     # Jakarta validation service
└── target/                           # Build output (generated)
    └── azure-functions/              # Packaged Azure Functions (generated)
```

### Key Dependencies
- Azure Functions Java Library 3.0.0
- Jakarta Validation API 3.0.2
- Hibernate Validator 7.0.5.Final
- Jackson Databind 2.14.2
- JUnit Jupiter 5.4.2 (test scope)
- Mockito 2.23.4 (test scope)

### Build Targets
- `mvn clean` -- removes target directory
- `mvn compile` -- compiles source code (1 minute)
- `mvn package` -- creates deployable package with Azure Functions runtime (2+ minutes)
- `mvn azure-functions:deploy` -- deploys to Azure (requires Azure configuration)

### Environment Requirements
- Java 11+ (configured in pom.xml, tested with OpenJDK 17)
- Maven 3.6+
- Azure Functions Core Tools v4+ (for local execution)
- Internet connectivity (for Azure Functions extension bundles and dependencies)

### Local Development Configuration
The application supports both identity-based authentication (production) and connection string authentication (local development).

#### Identity-Based Configuration (Production/Deployed)
The deployed Function App uses managed identity for secure, credential-free access:
- **Service Bus**: Uses `ServiceBusConnection__fullyQualifiedNamespace` and `ServiceBusConnection__credential=managedidentity`
- **Storage**: Uses `AzureWebJobsStorage__accountName` and `AzureWebJobsStorage__credential=managedidentity`

#### Connection String Configuration (Local Development)
For local development, use the traditional connection string approach:
- Copy `local.settings.json.template` to `local.settings.json` 
- Configure connection strings for Service Bus and Storage Account
- The template provides both identity-based and connection string examples

Example local.settings.json for development:
```json
{
  "IsEncrypted": false,
  "Values": {
    "FUNCTIONS_WORKER_RUNTIME": "java",
    "ServiceBusConnection": "Endpoint=sb://your-namespace.servicebus.windows.net/;SharedAccessKeyName=your-key;SharedAccessKey=your-secret",
    "AzureWebJobsStorage": "DefaultEndpointsProtocol=https;AccountName=storageaccount;AccountKey=key;EndpointSuffix=core.windows.net"
  }
}
```

### Troubleshooting
- **Build timeouts**: Maven downloads many dependencies on first run. Allow 3+ minutes for initial build.
- **Local runtime failures**: Azure Functions runtime requires internet access. Network restrictions prevent extension bundle downloads.
- **Java version issues**: Ensure Java 11+ is used. The application is configured for Java 11 target but works with later versions.
- **Service Bus connection**: ReceiveOrder function requires valid Service Bus connection string for local testing.
- **Checkstyle failures**: Code currently has 289+ style violations with default Sun checks. Focus on functionality rather than style compliance.

### Function Endpoints
When running locally (with internet connectivity):
- ReceiveOrder: `POST http://localhost:7071/api/ReceiveOrder`

### Validation Scenarios
Always test these scenarios after making changes:
1. **Order validation**: Ensure OrderValidation.isValidOrder() correctly validates required fields and constraints
2. **JSON serialization**: Verify OrderRequest and related models serialize/deserialize correctly with Jackson
3. **Line item calculations**: Confirm LineItem.getTotalPrice() returns quantity * unitPrice
4. **Build process**: Ensure `mvn package` completes without errors and generates Azure Functions runtime artifacts

### Architecture Notes
- **ReceiveOrder**: Production-style function accepting OrderRequest JSON, validating it, and forwarding to Service Bus queue
- **Validation**: Uses Jakarta Bean Validation with Hibernate Validator for request validation
- **Models**: Well-structured POJOs with proper getters/setters and validation annotations
- **Services**: Single validation service using factory pattern for validator creation

Always run the manual business logic validation test after making any changes to ensure core functionality remains intact.