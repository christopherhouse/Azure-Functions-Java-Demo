# Copilot Instructions for Azure Functions Java Development

## Overview
This repository contains a Java-based Azure Functions solution for order processing. When working on this codebase, follow these comprehensive guidelines for Java development, Azure Functions best practices, and maintaining quality documentation.

## Java Development Best Practices

### Code Structure and Organization
- **Package Structure**: Follow the existing package hierarchy `com.christopherhouse.functions.*`
- **Separation of Concerns**: Keep business logic separate from Azure Functions infrastructure code
  - Functions classes should focus on HTTP/trigger handling
  - Business logic should be in dedicated service classes
  - Data models should be in separate model packages
- **Naming Conventions**: Use clear, descriptive names following Java conventions
  - Classes: PascalCase (e.g., `OrderValidation`)
  - Methods: camelCase (e.g., `isValidOrder`)
  - Constants: UPPER_SNAKE_CASE
  - Packages: lowercase with dots (e.g., `com.christopherhouse.functions.models`)

### Code Quality Standards
- **Null Safety**: Always check for null values and use `Optional<T>` when appropriate
- **Exception Handling**: Implement proper exception handling with meaningful error messages
  - Log exceptions with context information
  - Return appropriate HTTP status codes for different error scenarios
- **Input Validation**: Use Jakarta Bean Validation annotations (`@NotNull`, `@Email`, etc.)
- **Immutability**: Prefer immutable objects where possible, especially for data transfer objects
- **Single Responsibility**: Each class and method should have a single, well-defined purpose

### Testing Guidelines
- **Unit Tests**: Write unit tests for all business logic using JUnit 5
- **Test Coverage**: Aim for high test coverage, especially for critical business logic
- **Test Structure**: Follow Arrange-Act-Assert pattern
- **Mocking**: Use Mockito for mocking dependencies and external services
- **Test Naming**: Use descriptive test method names that explain the scenario being tested

### Dependency Management
- **Maven Dependencies**: Keep dependencies up to date and remove unused ones
- **Version Management**: Use properties in `pom.xml` for version management
- **Scope Management**: Use appropriate dependency scopes (compile, test, provided)

## Azure Functions Best Practices

### Function Design Principles
- **Stateless**: Functions should be stateless and idempotent
- **Single Purpose**: Each function should have a single, well-defined responsibility
- **Fast Startup**: Minimize cold start times by avoiding heavy initialization
- **Resource Efficiency**: Design functions to be resource-efficient and scale well

### Configuration Management
- **Environment Variables**: Use environment variables for configuration, not hard-coded values
- **Connection Strings**: Store connection strings in Azure App Settings
- **Secrets Management**: Use Azure Key Vault for sensitive data
- **Configuration Validation**: Validate configuration on startup

### Error Handling and Logging
- **Structured Logging**: Use structured logging with context information
- **Correlation IDs**: Include correlation IDs for request tracing
- **Error Responses**: Return meaningful error messages with appropriate HTTP status codes
- **Retry Logic**: Implement retry logic for transient failures
- **Dead Letter Queues**: Configure dead letter queues for message processing functions

### Performance Optimization
- **Connection Pooling**: Reuse connections where possible
- **Async Operations**: Use asynchronous operations for I/O bound tasks
- **Batch Processing**: Process messages in batches when appropriate
- **Resource Limits**: Configure appropriate timeout and memory limits

## Azure Functions on Java Specific Guidelines

### Function App Configuration
- **Java Version**: Use supported Java versions (Java 11 is used in this project)
- **Runtime Configuration**: Configure the runtime in `host.json` appropriately
- **Extension Bundles**: Use extension bundles for better dependency management

### Binding Best Practices
- **Input Bindings**: Use appropriate input bindings for different trigger types
- **Output Bindings**: Leverage output bindings for efficient data writing
- **Binding Expressions**: Use binding expressions for dynamic configuration
- **Custom Bindings**: Create custom bindings when needed for reusability

### Memory and Performance
- **JVM Tuning**: Configure JVM settings appropriately for the function app
- **Garbage Collection**: Monitor and optimize garbage collection settings
- **Class Loading**: Minimize class loading overhead during cold starts
- **Native Compilation**: Consider GraalVM native compilation for performance-critical scenarios

### Integration Patterns
- **Service Bus**: Use Service Bus for reliable message processing (as implemented in `ReceiveOrder`)
- **Cosmos DB**: Use Cosmos DB bindings for document storage
- **Blob Storage**: Use blob triggers and bindings for file processing
- **Event Hubs**: Use Event Hubs for high-throughput event processing

### Security Best Practices
- **Authentication**: Configure appropriate authentication levels for functions
- **Authorization**: Implement proper authorization checks
- **Input Sanitization**: Sanitize and validate all inputs
- **CORS Configuration**: Configure CORS appropriately for web scenarios

## Documentation and README Maintenance

### README Requirements
Always maintain a comprehensive README.md that includes:

1. **Project Overview**: Clear description of what the solution does
2. **Architecture**: Explanation of the solution architecture and components
3. **Prerequisites**: List all required tools, services, and dependencies
4. **Setup Instructions**: Step-by-step setup and configuration guide
5. **Local Development**: How to run and test the functions locally
6. **Deployment**: Instructions for deploying to Azure
7. **Configuration**: Explanation of all configuration options
8. **API Documentation**: Detailed API documentation for all functions
9. **Testing**: How to run tests and what they cover
10. **Troubleshooting**: Common issues and their solutions
11. **Contributing**: Guidelines for contributing to the project

### Code Documentation
- **JavaDoc**: Use JavaDoc comments for public APIs and complex methods
- **Inline Comments**: Add comments for complex business logic
- **Configuration Comments**: Document configuration options and their purposes
- **Architecture Decisions**: Document significant architectural decisions

### Keeping Documentation Current
- **Update with Changes**: Always update documentation when making code changes
- **Review Regularly**: Regularly review and update documentation for accuracy
- **Examples**: Include code examples and sample requests/responses
- **Links**: Keep external links current and functional

## Monitoring and Observability

### Application Insights Integration
- **Telemetry**: Implement custom telemetry for business metrics
- **Performance Monitoring**: Monitor function performance and duration
- **Dependency Tracking**: Track external dependency calls
- **Custom Events**: Log custom events for business intelligence

### Health Checks
- **Health Endpoints**: Implement health check endpoints
- **Dependency Health**: Check health of external dependencies
- **Resource Monitoring**: Monitor resource usage and limits

## Development Workflow

### Code Review Guidelines
- **Review Checklist**: Use a consistent code review checklist
- **Security Review**: Always review code for security vulnerabilities
- **Performance Review**: Consider performance implications of changes
- **Documentation Review**: Ensure documentation is updated with changes

### Continuous Integration
- **Build Automation**: Ensure all builds are automated and reproducible
- **Test Automation**: Run all tests automatically on code changes
- **Quality Gates**: Implement quality gates for code coverage and analysis
- **Deployment Automation**: Automate deployment processes

### Version Control
- **Commit Messages**: Use clear, descriptive commit messages
- **Branch Strategy**: Follow a consistent branch strategy
- **Pull Requests**: Use pull requests for all changes with proper reviews

Remember: These guidelines should be followed consistently across all development work on this Azure Functions Java solution. Always prioritize code quality, security, and maintainability while keeping the documentation accurate and helpful.