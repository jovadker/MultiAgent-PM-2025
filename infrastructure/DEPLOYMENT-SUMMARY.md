# Bicep Infrastructure Deployment - Summary

## 📋 What Was Generated

This deployment includes comprehensive Infrastructure as Code (IaC) using Azure Bicep to automate the complete infrastructure deployment for the Multi-Agent Portfolio Management system.

### Files Created

1. **main.bicep** (370 lines)
   - Complete infrastructure template for Azure Function Flex Consumption
   - AI Foundry (Cognitive Services) with DeepSeek-V3.1 model deployment
   - Storage Account with blob container for deployment packages
   - Application Insights and Log Analytics for monitoring
   - Managed Identity with proper RBAC role assignments
   - All configurations and application settings

2. **main.parameters.json**
   - Environment-specific parameter values
   - Configurable for dev/test/prod environments
   - Pre-configured with your existing resource names

3. **deploy.ps1** (PowerShell deployment script)
   - Automated deployment orchestration
   - Includes validation, resource creation, and code deployment
   - What-if analysis support
   - Comprehensive error handling and logging

4. **validate.ps1** (PowerShell validation script)
   - Pre-deployment validation checks
   - Template syntax validation
   - Parameter validation
   - Azure login status verification

5. **infrastructure/README.md** (320 lines)
   - Complete deployment documentation
   - Step-by-step instructions
   - Troubleshooting guide
   - Post-deployment verification steps

## 🎯 Key Features

### Azure Function (Flex Consumption Plan)
- **Runtime**: .NET 8.0 (isolated worker)
- **Platform**: Linux
- **Scaling**: 40-1000 instances, 2048MB per instance
- **Authentication**: Managed Identity (no connection strings)
- **Deployment**: Blob container storage with identity-based auth

### AI Foundry (Cognitive Services)
- **Kind**: AIServices (multi-service account)
- **Model**: DeepSeek-V3.1 deployment
- **Format**: OpenAI API compatible
- **Capacity**: Standard tier with 10 units
- **Endpoint**: Configured with custom subdomain

### Security & Best Practices
- ✅ Managed Identity authentication (no secrets)
- ✅ HTTPS only with TLS 1.2+
- ✅ Shared key access disabled on storage
- ✅ Least privilege RBAC assignments
- ✅ Network ACLs configured
- ✅ Application Insights with managed identity

### Monitoring & Diagnostics
- Application Insights for telemetry
- Log Analytics workspace (30-day retention)
- Managed identity authentication
- Custom instrumentation key
- Automatic dependency tracking

## 🚀 Quick Deployment

### Method 1: Automated Script (Recommended)
```powershell
cd infrastructure
.\deploy.ps1
```

### Method 2: Azure CLI
```powershell
az deployment group create \
  --resource-group AIFoundry.StockTrading.RG \
  --template-file main.bicep \
  --parameters main.parameters.json
```

### Method 3: With Validation First
```powershell
.\validate.ps1
.\deploy.ps1 -WhatIf  # Preview changes
.\deploy.ps1          # Deploy
```

## 📊 Deployment Timeline

| Phase | Duration | Description |
|-------|----------|-------------|
| Validation | 10 seconds | Template and parameter validation |
| Resource Group | 5 seconds | Create or verify resource group |
| Storage Account | 30 seconds | Create storage with blob container |
| Managed Identity | 15 seconds | Create user-assigned identity |
| RBAC Assignments | 60 seconds | Assign roles (storage, monitoring, AI) |
| App Insights | 20 seconds | Create monitoring resources |
| App Service Plan | 10 seconds | Create Flex Consumption plan |
| Function App | 90 seconds | Create and configure function app |
| AI Foundry | 120 seconds | Create Cognitive Services account |
| Model Deployment | 60 seconds | Deploy DeepSeek-V3.1 model |
| Code Deployment | 90 seconds | Build and upload function code |
| **Total** | **~8 minutes** | Complete end-to-end deployment |

## 📦 Resources Deployed

| Resource Type | Resource Name | Purpose |
|---------------|---------------|---------|
| Storage Account | `st{resourceToken}` | Function runtime storage |
| Function App | `function-mcpagent` | MCP Server host |
| App Service Plan | `plan-{resourceToken}` | Flex Consumption plan |
| Cognitive Services | `aifoundry-stocktrading` | AI Foundry + DeepSeek model |
| Managed Identity | `uai-function-mcpagent-{token}` | Secure authentication |
| Log Analytics | `log-{resourceToken}` | Log aggregation |
| App Insights | `appi-{resourceToken}` | Application monitoring |
| Blob Container | `app-package-{name}-{token}` | Deployment packages |
| Model Deployment | `DeepSeek-V3.1` | AI model endpoint |

## ⚙️ Configuration

### Pre-configured Settings
The template automatically configures these application settings:

```json
{
  "AzureWebJobsStorage__accountName": "st{resourceToken}",
  "AzureWebJobsStorage__credential": "managedidentity",
  "AzureWebJobsStorage__clientId": "{managed-identity-client-id}",
  "APPINSIGHTS_INSTRUMENTATIONKEY": "{instrumentation-key}",
  "APPLICATIONINSIGHTS_AUTHENTICATION_STRING": "ClientId={client-id};Authorization=AAD",
  "AZURE_OPENAI_ENDPOINT": "https://aifoundry-stocktrading.openai.azure.com",
  "AZURE_OPENAI_DEPLOYMENT_NAME": "DeepSeek-V3.1",
  "MCP_SERVER_PORT": "5000",
  "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
  "FUNCTIONS_EXTENSION_VERSION": "~4",
  "ENVIRONMENT": "dev"
}
```

### RBAC Roles Assigned
The managed identity is automatically assigned these roles:

- **Storage Blob Data Owner** - Full access to deployment blobs
- **Storage Blob Data Contributor** - Blob read/write access
- **Storage Queue Data Contributor** - Queue operations
- **Storage Table Data Contributor** - Table operations
- **Monitoring Metrics Publisher** - Publish metrics to App Insights
- **Cognitive Services User** - Access AI Foundry endpoints

## 🔍 Verification

After deployment, verify with these commands:

```powershell
# List all resources
az resource list --resource-group AIFoundry.StockTrading.RG --output table

# Get Function App URL
az functionapp show --name function-mcpagent \
  --resource-group AIFoundry.StockTrading.RG \
  --query defaultHostName -o tsv

# Get AI Foundry endpoint
az cognitiveservices account show \
  --name aifoundry-stocktrading \
  --resource-group AIFoundry.StockTrading.RG \
  --query properties.endpoint -o tsv

# Check deployment status
az functionapp show --name function-mcpagent \
  --resource-group AIFoundry.StockTrading.RG \
  --query state -o tsv
```

## 🌍 Supported Regions

Flex Consumption is available in:
- East US
- East US 2
- West US 2
- West US 3
- North Europe
- West Europe
- UK South
- Southeast Asia

## 💰 Cost Estimation

Approximate monthly costs (dev environment):

| Resource | SKU/Tier | Est. Monthly Cost |
|----------|----------|-------------------|
| Function App (Flex) | FC1 | $0-50 (usage-based) |
| Storage Account | Standard_LRS | $1-5 |
| Application Insights | Pay-as-you-go | $2-10 |
| Log Analytics | PerGB2018 | $2-5 |
| Cognitive Services | S0 | $0 (first 1M tokens free) |
| **Total** | | **$5-70/month** |

*Production costs will be higher based on actual usage*

## 📚 Documentation Links

- [Azure Functions Flex Consumption](https://learn.microsoft.com/azure/azure-functions/flex-consumption-plan)
- [Azure AI Foundry](https://learn.microsoft.com/azure/ai-services/)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [DeepSeek Models](https://learn.microsoft.com/azure/ai-services/openai/concepts/models)
- [Managed Identities](https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/)

## 🛠️ Troubleshooting

### Common Issues

**1. Deployment timeout**
- Solution: Re-run the deployment script
- The deployment is idempotent and safe to retry

**2. Name already exists**
- Solution: Change `resourceToken` in parameters file
- Storage account names must be globally unique

**3. Insufficient permissions**
- Solution: Ensure you have Owner or Contributor + User Access Administrator
- Required to create role assignments

**4. Region not supported**
- Solution: Change location to supported region in parameters file
- Check supported regions list above

## ✅ Next Steps

After successful deployment:

1. **Test the Function App**
   - Navigate to the function URL
   - Verify the welcome page loads

2. **Configure Power Platform**
   - Import the Copilot Studio solution
   - Configure the MCP endpoint to use the function URL

3. **Monitor Application**
   - Open Application Insights in Azure Portal
   - Review live metrics and logs

4. **Set up CI/CD** (optional)
   - Configure GitHub Actions or Azure DevOps
   - Automate deployments from source control

## 🔐 Security Recommendations

For production deployments, consider:

- [ ] Enable private endpoints for storage and AI Foundry
- [ ] Configure virtual network integration
- [ ] Set up Azure Key Vault for additional secrets
- [ ] Enable Azure Defender for Cloud
- [ ] Configure Azure Policy compliance
- [ ] Set up diagnostic settings for all resources
- [ ] Enable soft delete on storage accounts
- [ ] Configure backup retention policies

---

**Generated**: January 2025  
**Version**: 1.0  
**Template API Versions**:
- Microsoft.Web/serverfarms: 2024-04-01
- Microsoft.Web/sites: 2024-04-01
- Microsoft.Storage/storageAccounts: 2023-05-01
- Microsoft.CognitiveServices/accounts: 2024-10-01
- Microsoft.Insights/components: 2020-02-02
