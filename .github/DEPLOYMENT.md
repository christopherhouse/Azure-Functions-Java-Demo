# GitHub Actions CI/CD Setup Guide

This repository includes GitHub Actions workflows for automated CI/CD deployment of the Azure Functions Java application.

## Overview

The CI/CD pipeline consists of two workflows:

1. **Main CI/CD Pipeline** (`.github/workflows/main.yml`)
   - Triggers on push to `main`/`develop` branches, PRs to `main`, and manual dispatch
   - Builds, tests, and packages the Java application 
   - Creates artifacts for Terraform code and Function App
   - Deploys to dev (on `develop` branch) or prod (on `main` branch)

2. **Reusable Deployment Workflow** (`.github/workflows/deploy.yml`)
   - Deploys infrastructure using Terraform
   - Deploys Function App package
   - Configures app settings with managed identity

## Prerequisites

### 1. Azure Setup

Before using the workflows, you need:

1. **Azure subscription** with appropriate permissions
2. **Service Principal or Managed Identity** for GitHub Actions
3. **Terraform backend storage** (follow terraform/README.md for setup)

### 2. GitHub Environments Configuration

Create two GitHub environments: `dev` and `prod`

#### For each environment, configure these secrets:

- `AZURE_CLIENT_ID` - Client ID of the Azure AD application/service principal
- `AZURE_TENANT_ID` - Azure AD tenant ID  
- `AZURE_SUBSCRIPTION_ID` - Azure subscription ID

#### OIDC Setup (Recommended)

The workflows use OpenID Connect (OIDC) for secure authentication without storing long-lived secrets.

1. Create an Azure AD application
2. Configure federated credentials for GitHub Actions
3. Grant appropriate permissions to the service principal

For detailed OIDC setup instructions, see: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure

## Workflow Features

### Build Stage
- ✅ Java 11 compilation with Maven
- ✅ Unit tests and manual validation tests
- ✅ Azure Functions packaging
- ✅ Artifact creation (terraform + function app)

### Deploy Stage  
- ✅ Azure login with OIDC federated credentials
- ✅ Terraform infrastructure deployment
- ✅ Function App deployment
- ✅ Managed identity configuration for Service Bus and Storage
- ✅ Deployment verification

### Security Features
- ✅ No long-lived secrets (uses OIDC)
- ✅ Identity-based authentication (no connection strings)
- ✅ Environment-specific deployments
- ✅ Terraform state management

## Triggering Deployments

### Automatic Deployments
- **Dev environment**: Push to `develop` branch
- **Prod environment**: Push to `main` branch

### Manual Deployments
1. Go to Actions tab in GitHub
2. Select "CI/CD Pipeline" workflow
3. Click "Run workflow"
4. Choose environment (dev/prod)
5. Optionally skip tests

## Infrastructure

The terraform configuration creates:
- Resource Group
- Storage Account (with managed identity)
- Service Bus namespace with topics/subscriptions
- Log Analytics workspace
- Application Insights
- User-assigned managed identity
- Function App with App Service Plan
- RBAC assignments for managed identity access

## Environment Differences

| Feature | Dev | Prod |
|---------|-----|------|
| App Service Plan | Consumption (Y1) | Premium (EP1) |
| Service Bus SKU | Standard | Premium |
| Storage Replication | LRS | GRS |
| Log Retention | 30 days | 90 days |
| Always On | No | Yes |

## Troubleshooting

### Common Issues

1. **"Azure login failed"**
   - Check OIDC configuration
   - Verify secrets are set correctly
   - Ensure service principal has required permissions

2. **"Terraform backend not found"**
   - Create backend storage per terraform/README.md
   - Check backend.conf files in environments/

3. **"Function App deployment failed"**
   - Verify Function App was created by Terraform
   - Check artifact contains correct Azure Functions structure

### Logs and Monitoring

- Check GitHub Actions logs for detailed error messages
- Monitor Azure Application Insights for Function App performance
- Review terraform state for infrastructure status

## Local Development

To test changes locally:
1. Follow the build steps in the main workflow
2. Use `terraform/deploy.sh` for infrastructure deployment  
3. Use Azure Functions Core Tools for local testing

For more details, see the repository README.md.