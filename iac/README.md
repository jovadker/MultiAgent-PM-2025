# Infrastructure as Code - Bicep Templates

This directory contains Bicep templates for deploying the Multi-Agent Portfolio Management system to Azure.

## Architecture Overview

The infrastructure deployment creates the following Azure resources:

### Core Resources
1. **Azure Function (Flex Consumption)** - Serverless compute for MCP Server
   - Runtime: .NET 8.0 (isolated worker)
   - Scaling: 40-1000 instances, 2048MB memory per instance
   - Linux-based Flex Consumption plan

2. **AI Foundry (Cognitive Services)** - AI model hosting
   - Kind: AIServices (multi-service account)
   - Model: DeepSeek-V3.1 deployment
   - Endpoint: https://aifoundry-stocktrading.openai.azure.com

3. **Storage Account** - Function app storage and deployment packages
   - SKU: Standard_LRS
   - Managed identity authentication
   - Blob container for deployment packages

4. **Application Insights** - Monitoring and telemetry
   - Connected to Log Analytics workspace
   - Integrated with Function App

5. **Managed Identity** - Secure authentication
   - User-assigned managed identity
   - RBAC roles for storage, monitoring, and AI services

## Prerequisites

Before deploying, ensure you have:

1. **Azure CLI** installed and authenticated
   ```bash
   az login
   az account set --subscription <subscription-id>
   ```

2. **Bicep CLI** installed
   ```bash
   az bicep install
   ```

3. **Resource Group** created
   ```bash
   az group create --name AIFoundry.StockTrading.RG --location eastus
   ```

4. **Permissions** - You need:
   - Owner or Contributor role on the subscription or resource group
   - Permission to create role assignments

## Deployment

### Option 1: Deploy with Azure CLI (Recommended)

```bash
# Navigate to infrastructure directory
cd infrastructure

# Deploy to Azure
az deployment group create \
  --resource-group AIFoundry.StockTrading.RG \
  --template-file main.bicep \
  --parameters main.parameters.json
```

### Option 2: Deploy with specific parameters

```bash
az deployment group create \
  --resource-group AIFoundry.StockTrading.RG \
  --template-file main.bicep \
  --parameters location=eastus \
               functionAppRuntime=dotnet-isolated \
               functionAppRuntimeVersion=8.0 \
               environment=dev
```

### Option 3: Deploy with Azure PowerShell

```powershell
# Navigate to infrastructure directory
cd infrastructure

# Deploy to Azure
New-AzResourceGroupDeployment `
  -ResourceGroupName AIFoundry.StockTrading.RG `
  -TemplateFile main.bicep `
  -TemplateParameterFile main.parameters.json
```

## Parameter Configuration

Edit `main.parameters.json` to customize your deployment:

| Parameter | Description | Default | Allowed Values |
|-----------|-------------|---------|----------------|
| `location` | Azure region | eastus | Any Azure region supporting Flex Consumption |
| `functionAppRuntime` | Function runtime | dotnet-isolated | dotnet-isolated, python, java, node, powerShell |
| `functionAppRuntimeVersion` | Runtime version | 8.0 | 3.10, 3.11, 7.4, 8.0, 9.0, 10, 11, 17, 20 |
| `maximumInstanceCount` | Max scale-out instances | 100 | 40-1000 |
| `instanceMemoryMB` | Memory per instance | 2048 | 2048, 4096 |
| `resourceToken` | Unique naming token | stocktrading001 | Min 3 characters |
| `functionAppName` | Function App name | function-mcpagent | Unique name |
| `aiFoundryName` | AI Foundry name | aifoundry-stocktrading | Unique name |
| `environment` | Environment name | dev | dev, test, prod |

## Post-Deployment Steps

After successful deployment:

1. **Verify Resources**
   ```bash
   az resource list --resource-group AIFoundry.StockTrading.RG --output table
   ```

2. **Get Function App URL**
   ```bash
   az functionapp show --name function-mcpagent \
     --resource-group AIFoundry.StockTrading.RG \
     --query defaultHostName --output tsv
   ```

3. **Get AI Foundry Endpoint**
   ```bash
   az cognitiveservices account show \
     --name aifoundry-stocktrading \
     --resource-group AIFoundry.StockTrading.RG \
     --query properties.endpoint --output tsv
   ```

4. **Deploy Function Code**
   
   Build and publish the function app:
   ```bash
   cd ../McpAzureFunction
   dotnet publish --configuration Release --output ./publish
   
   # Create deployment package
   cd publish
   zip -r ../released-package.zip .
   cd ..
   
   # Deploy to Azure
   az functionapp deployment source config-zip \
     --resource-group AIFoundry.StockTrading.RG \
     --name function-mcpagent \
     --src released-package.zip
   ```

5. **Configure Application Settings** (if needed)
   ```bash
   az functionapp config appsettings set \
     --name function-mcpagent \
     --resource-group AIFoundry.StockTrading.RG \
     --settings "CUSTOM_SETTING=value"
   ```

## Supported Regions for Flex Consumption

Flex Consumption plan is available in these regions:
- East US
- East US 2
- West US 2
- West US 3
- North Europe
- West Europe
- UK South
- Southeast Asia

Check [Microsoft documentation](https://learn.microsoft.com/azure/azure-functions/flex-consumption-how-to#view-currently-supported-regions) for the latest list.

## Resource Naming Convention

The template uses this naming convention:

| Resource Type | Naming Pattern | Example |
|---------------|----------------|---------|
| Storage Account | `st{resourceToken}` | `ststocktrading001` |
| Function App | `function-mcpagent` | `function-mcpagent` |
| App Service Plan | `plan-{resourceToken}` | `plan-stocktrading001` |
| AI Foundry | `aifoundry-stocktrading` | `aifoundry-stocktrading` |
| Managed Identity | `uai-{functionAppName}-{resourceToken}` | `uai-function-mcpagent-stocktrading001` |
| Log Analytics | `log-{resourceToken}` | `log-stocktrading001` |
| App Insights | `appi-{resourceToken}` | `appi-stocktrading001` |

## Security Features

The deployment implements security best practices:

1. **Managed Identity Authentication** - No connection strings or keys stored
2. **HTTPS Only** - All traffic encrypted with TLS 1.2+
3. **Shared Key Access Disabled** - Storage uses identity-based authentication
4. **Least Privilege RBAC** - Minimal permissions assigned
5. **Private Endpoints** - Optional for production environments
6. **Network ACLs** - Configurable network restrictions

## Monitoring and Diagnostics

Application Insights is automatically configured to capture:

- Function execution traces
- Performance metrics
- Request telemetry
- Dependency tracking
- Custom events and metrics

Access Application Insights:
```bash
az monitor app-insights component show \
  --app appi-{resourceToken} \
  --resource-group AIFoundry.StockTrading.RG
```

## Troubleshooting

### Deployment Failures

1. **Insufficient permissions**
   - Ensure you have Owner or Contributor + User Access Administrator roles
   - Required to create role assignments

2. **Region not supported**
   - Verify the region supports Flex Consumption plan
   - Use `az account list-locations` to see available regions

3. **Name conflicts**
   - Storage account names must be globally unique
   - AI Foundry custom subdomain must be globally unique
   - Change `resourceToken` parameter to generate unique names

4. **Quota limits**
   - Check subscription quotas: `az vm list-usage --location eastus`
   - Request quota increase if needed

### Validation Before Deployment

Run what-if analysis to preview changes:
```bash
az deployment group what-if \
  --resource-group AIFoundry.StockTrading.RG \
  --template-file main.bicep \
  --parameters main.parameters.json
```

## Clean Up Resources

To delete all resources:

```bash
az group delete --name AIFoundry.StockTrading.RG --yes --no-wait
```

⚠️ **Warning**: This permanently deletes all resources in the resource group!

## Additional Resources

- [Azure Functions Flex Consumption Plan](https://learn.microsoft.com/azure/azure-functions/flex-consumption-plan)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure AI Foundry](https://learn.microsoft.com/azure/ai-services/)
- [Managed Identities](https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/)
- [DeepSeek Models in Azure](https://learn.microsoft.com/azure/ai-services/openai/concepts/models)

## Support

For issues or questions:
1. Check Azure deployment logs: `az deployment group show --name <deployment-name> --resource-group <rg-name>`
2. Review Application Insights logs
3. Check Azure service health status
4. Contact Azure support if needed
