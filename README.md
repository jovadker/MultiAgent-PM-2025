# MultiAgent-PM-2025

**Multi-Agent Portfolio Management System with Azure Functions (Flex Consumption) and AI Foundry**

[![Azure](https://img.shields.io/badge/Azure-Functions%20Flex-0078D4?logo=microsoftazure)](https://azure.microsoft.com/en-us/products/functions)
[![.NET](https://img.shields.io/badge/.NET-8.0-512BD4?logo=dotnet)](https://dotnet.microsoft.com/)
[![Bicep](https://img.shields.io/badge/IaC-Bicep-0078D4?logo=microsoftazure)](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
[![AI Foundry](https://img.shields.io/badge/AI-DeepSeek%20V3.1-00A4EF)](https://azure.microsoft.com/en-us/products/ai-services)

## 🚀 Quick Start

Deploy the complete infrastructure in ~8 minutes:

```powershell
cd infrastructure
.\deploy.ps1
```

**What gets deployed:**
- ✅ Azure Function (Flex Consumption, .NET 8)
- ✅ AI Foundry with DeepSeek-V3.1 model
- ✅ Storage, Monitoring, Managed Identity, RBAC

📖 **Full guide**: [Deployment Documentation](#deployment) | [Infrastructure README](infrastructure/README.md)

---

## Overview

This repository contains a multi-agent system for stock trading and portfolio management, built using Microsoft Copilot Studio and Azure Functions with Infrastructure-as-Code (Bicep) deployment. The solution consists of:

1. **Azure Function App (MCP Server)** - A Model Context Protocol (MCP) server providing tools for mathematical operations and AI-powered translation
2. **Power Platform Solution** - A Copilot Studio solution with three interconnected agents for stock trading and portfolio management
3. **Bicep Infrastructure** - Complete Infrastructure-as-Code templates for automated Azure deployment

## Architecture

The solution uses a serverless architecture on Azure with AI capabilities powered by Azure AI Foundry:

```
┌─────────────────────────────────────────────────────────────┐
│                   Power Platform                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Copilot Studio Agents                         │  │
│  │  • PortfolioManagerAgent (Orchestrator)              │  │
│  │  • StockTraderAgent (Execution)                      │  │
│  │  • InvestorAgent (Analysis)                          │  │
│  └──────────────────────────┬───────────────────────────┘  │
└────────────────────────────┼──────────────────────────────┘
                             │ HTTPS/MCP
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    Azure Function                           │
│              (Flex Consumption Plan)                        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │       MCP Server (.NET 8 Isolated)                   │  │
│  │  • MathTool (calculations)                           │  │
│  │  • TranslateTool (AI translation)                    │  │
│  └──────────────────────┬───────────────────────────────┘  │
└──────────────────────────┼────────────────────────────────┘
                           │ Azure OpenAI API
                           ▼
┌─────────────────────────────────────────────────────────────┐
│           Azure AI Foundry (Cognitive Services)             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │    DeepSeek-V3.1 Model Deployment                    │  │
│  │  • Language Translation                              │  │
│  │  • AI-powered reasoning                              │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 1. Azure Function - MCP Server (`McpAzureFunction`)

The Azure Function implements a Model Context Protocol (MCP) server that exposes AI-powered tools and utilities. It's built on:

- **.NET 8.0** with Azure Functions v4
- **Flex Consumption Plan** for optimal scaling and cost efficiency
- **Model Context Protocol (MCP)** for tool exposure
- **Azure AI Foundry** integration for AI capabilities
- **Isolated worker runtime** for better performance and security
- **Managed Identity** authentication for secure resource access

#### Available Tools

##### MathTool
Provides basic mathematical operations:
- `Add(a, b)` - Adds two numbers
- `Greet(name)` - Returns a greeting message
- `CalculateRectangleArea(width, height)` - Calculates rectangle area

##### TranslateTool
AI-powered translation using Azure OpenAI:
- `Translate(text, targetLanguage, sourceLanguage?)` - Translates text between languages using DeepSeek-V3.1 model
- `GetSupportedLanguages()` - Returns list of commonly supported languages (English, Spanish, French, German, Italian, Portuguese, Russian, Japanese, Korean, Chinese, Arabic, Hindi, Dutch, Polish, Turkish)

#### Configuration

The function uses:
- **Azure OpenAI Endpoint**: `https://aifoundry-stocktrading.openai.azure.com`
- **Model**: DeepSeek-V3.1
- **Authentication**: DefaultAzureCredential with Entra ID tenant
- **Runtime**: Dotnet-isolated

### 2. Power Platform Solution - Copilot Studio Agents

The `StockTradingSolution` contains three specialized agents working together:

#### Agent 1: PortfolioManagerAgent (`jvz_agent`)
- **Name**: PortfolioManagerAgent
- **Purpose**: Main orchestrator agent that manages the portfolio and coordinates with other agents
- **Configuration**:
  - Generative Actions Enabled
  - Agent Connectable
  - GPT Settings with custom schema
  - AI Settings: Model knowledge, file analysis, and semantic search enabled
  - Authentication: Integrated (Entra ID)
- **App ID**: b3a4333a-0bd7-4992-ad01-b77376053762

#### Agent 2: StockTraderAgent (`jvz_agent_iA9-Jx`)
- **Name**: StockTraderAgent
- **Purpose**: Handles stock trading operations and market analysis
- **Configuration**: Similar to PortfolioManagerAgent with specialized trading capabilities
- **Integration**: Connected to external data sources (finance.yahoo.com, msn.com/money)
- **Features**:
  - Computer use action capabilities
  - Web scraping for stock information
  - Real-time market data integration
- **App ID**: c2f3052f-ecc2-47b3-b144-5b4893dc7b40

#### Agent 3: InvestorAgent (`jvz_agent_w0713v`)
- **Name**: InvestorAgent
- **Purpose**: Provides investment advice and portfolio recommendations
- **Configuration**: Focused on investment strategy and analysis
- **App ID**: aadfae6b-5cac-4ea0-aef5-69de169fafe8

#### Agent Orchestration
- The PortfolioManagerAgent can invoke the other agents using connected agent task actions
- Workflow set includes connector actions (Office365Outlook - Send an email)
- Supports email notifications for portfolio updates

## Deployment

### Prerequisites

#### For Azure Infrastructure (Bicep Deployment)
1. **Azure Subscription** with permissions to:
   - Create resource groups
   - Deploy Azure Functions (Flex Consumption)
   - Create Cognitive Services (AI Foundry)
   - Create Storage Accounts
   - Assign RBAC roles
   - Create managed identities

2. **Tools Required**:
   - [Azure CLI](https://aka.ms/installazurecli) (version 2.50+)
   - [Bicep CLI](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install) (installed via Azure CLI)
   - PowerShell 7+ (for deployment scripts)
   - .NET 8.0 SDK (for function code compilation)

3. **Azure Permissions**:
   - Owner or Contributor + User Access Administrator role
   - Required for creating role assignments

#### For Power Platform (Copilot Studio)
1. **Power Platform Environment** with:
   - Copilot Studio license
   - Entra ID (Azure AD) integration
   - Power Automate access
   - Environment maker permissions

2. **Tools Required**:
   - [Power Platform CLI](https://aka.ms/PowerPlatformCLI) (optional, for automation)

### Deployment Steps

## Part 1: Deploy Azure Infrastructure (Bicep)

### 🚀 Automated Deployment (Recommended)

The fastest and most reliable way to deploy all Azure resources is using the provided Bicep Infrastructure-as-Code templates.

#### Prerequisites
- Azure CLI installed
- Azure subscription with appropriate permissions
- Resource group creation rights

#### Quick Deployment

```powershell
# Navigate to infrastructure directory
cd infrastructure

# Validate the template (optional)
.\validate.ps1

# Preview changes with what-if (optional)
.\deploy.ps1 -WhatIf

# Deploy everything
.\deploy.ps1
```

**OR** using Azure CLI directly:

```bash
# Login to Azure
az login --tenant 9b7dd4f7-a403-4500-afad-77b33b78b1d8

# Create resource group
az group create --name AIFoundry.StockTrading.RG --location eastus

# Deploy infrastructure
az deployment group create \
  --resource-group AIFoundry.StockTrading.RG \
  --template-file infrastructure/main.bicep \
  --parameters infrastructure/main.parameters.json
```

#### What Gets Deployed

The Bicep template automatically provisions:

| Resource | Configuration | Purpose |
|----------|--------------|----------|
| **Azure Function** | Flex Consumption, .NET 8, Linux | MCP Server host |
| **AI Foundry** | AIServices + DeepSeek-V3.1 | AI model deployment |
| **Storage Account** | Standard_LRS, managed identity auth | Function runtime storage |
| **Application Insights** | 30-day retention | Monitoring & telemetry |
| **Log Analytics** | PerGB2018 tier | Log aggregation |
| **Managed Identity** | User-assigned | Secure authentication |
| **RBAC Roles** | Storage, AI, Monitoring | Least privilege access |

⏱️ **Deployment time: ~8 minutes**

#### Post-Deployment Verification

```powershell
# List deployed resources
az resource list --resource-group AIFoundry.StockTrading.RG --output table

# Get Function App URL
az functionapp show --name function-mcpagent \
  --resource-group AIFoundry.StockTrading.RG \
  --query defaultHostName --output tsv

# Get AI Foundry endpoint
az cognitiveservices account show \
  --name aifoundry-stocktrading \
  --resource-group AIFoundry.StockTrading.RG \
  --query properties.endpoint --output tsv
```

#### Customization

To customize the deployment, edit `infrastructure/main.parameters.json`:

```json
{
  "parameters": {
    "location": { "value": "eastus" },
    "functionAppRuntime": { "value": "dotnet-isolated" },
    "maximumInstanceCount": { "value": 100 },
    "instanceMemoryMB": { "value": 2048 },
    "environment": { "value": "dev" }
  }
}
```

📖 **For detailed documentation, see: [infrastructure/README.md](infrastructure/README.md)**

---

### Manual Deployment (Alternative)

If you cannot use Bicep templates, follow the manual steps in [infrastructure/README.md](infrastructure/README.md#alternative-manual-deployment-steps).



## Part 2: Deploy to Power Platform / Copilot Studio

##### 1. Prepare the Solution File

The solution is packaged in `StockTradingSolution` directory as an unmanaged solution with the following components:
- 3 Bot definitions (agents)
- Topics and conversation flows
- Actions and connectors
- Generative AI configurations

##### 2. Import Solution to Power Platform

```powershell
# Option A: Using Power Platform CLI

# Install Power Platform CLI if not installed
# Download from: https://aka.ms/PowerPlatformCLI

# Authenticate to your environment
pac auth create --environment [YOUR-ENVIRONMENT-URL]

# Package the solution
pac solution pack `
  --zipfile StockTradingSolution.zip `
  --folder .\StockTradingSolution `
  --packagetype Unmanaged

# Import the solution
pac solution import `
  --path StockTradingSolution.zip `
  --activate-plugins
```

```powershell
# Option B: Using Power Platform Admin Center

# 1. Navigate to https://admin.powerplatform.microsoft.com
# 2. Select your environment
# 3. Go to Solutions
# 4. Click "Import solution"
# 5. Browse and select the StockTradingSolution folder or zip file
# 6. Follow the wizard to complete import
```

##### 3. Configure Agent Connections

After importing, configure the following:

**For StockTraderAgent:**
1. Open Copilot Studio
2. Navigate to StockTraderAgent
3. Configure connections:
   - Add HTTP connector for finance.yahoo.com
   - Add HTTP connector for msn.com/money
   - Configure Computer Use action capabilities

**For all agents:**
1. Configure Office365 Outlook connector for email notifications
2. Set up authentication flows (already configured for Integrated authentication)
3. Verify Generative AI settings point to your Azure OpenAI resource

##### 4. Connect Agents to MCP Function

1. In each agent's configuration, add the Azure Function as an action:
   ```
   Function URL: https://[function-app-name].azurewebsites.net/api/[function-name]
   Authentication: Use Managed Identity or Function Key
   ```

2. Test the MCP tools:
   - Test translation functionality
   - Test mathematical operations
   - Verify AI responses

##### 5. Configure Agent Orchestration

1. In PortfolioManagerAgent, configure the connected agent actions:
   - Link to StockTraderAgent for trading operations
   - Link to InvestorAgent for investment advice

2. Set up the workflow triggers:
   - Recurring triggers for portfolio updates
   - Event-based triggers for market changes

##### 6. Publish and Test

```powershell
# Publish each agent
# 1. Open Copilot Studio
# 2. Select each agent
# 3. Click "Publish"
# 4. Wait for publication to complete

# Test the solution
# 1. Use the Test Bot feature in Copilot Studio
# 2. Try sample conversations:
#    - "What's my portfolio performance?"
#    - "Buy 100 shares of MSFT"
#    - "Give me investment recommendations"
#    - "Translate 'Hello' to Spanish"
```

##### 7. Deploy to Channels (Optional)

Once tested, deploy the agents to desired channels:
- Microsoft Teams
- Web chat widget
- Power Virtual Agents portal
- Custom channels

## Configuration Details

### Azure Function Configuration

**local.settings.json** (for local development):
```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
    "AZURE_OPENAI_ENDPOINT": "https://aifoundry-stocktrading.openai.azure.com",
    "AZURE_OPENAI_MODEL": "DeepSeek-V3.1"
  }
}
```

**Application Settings** (Azure Portal):
- `AZURE_OPENAI_ENDPOINT`: Your Azure OpenAI endpoint
- `AZURE_OPENAI_MODEL`: Model deployment name
- Managed Identity enabled for authentication

### Copilot Studio Configuration

**Solution Details:**
- **Solution Name**: StockTradingSolution
- **Version**: 1.0.0.1
- **Publisher**: Vadkerti (vadkerti)
- **Customization Prefix**: jvz
- **Managed**: No (Unmanaged solution)

**Agent Templates:**
- Template version: default-2.1.0
- Language code: 1033 (English)
- Authentication mode: Integrated (Entra ID)

## Monitoring and Management

### Azure Function Monitoring

```powershell
# View function logs
az functionapp log tail `
  --name $functionAppName `
  --resource-group $resourceGroup

# Monitor with Application Insights (if configured)
# View in Azure Portal > Function App > Application Insights
```

### Copilot Studio Monitoring

1. **Analytics Dashboard**:
   - Navigate to Copilot Studio > Analytics
   - Monitor conversation metrics
   - Track agent performance

2. **Conversation Logs**:
   - View conversation transcripts
   - Debug agent responses
   - Identify areas for improvement

## Security Considerations

1. **Authentication**:
   - All agents use Integrated (Entra ID) authentication
   - Managed Identity for Azure Function to OpenAI communication
   - No API keys stored in code

2. **Data Protection**:
   - Conversations encrypted in transit and at rest
   - PII handling according to Microsoft data governance policies

3. **Access Control**:
   - RBAC for Azure resources
   - Security roles in Power Platform
   - App registrations properly configured

## Troubleshooting

### Infrastructure Deployment Issues

1. **Bicep deployment fails**:
   - Run `.\infrastructure\validate.ps1` to check template syntax
   - Verify Azure CLI is authenticated: `az account show`
   - Check region supports Flex Consumption (see [infrastructure/README.md](infrastructure/README.md))
   - Ensure you have Owner or Contributor + User Access Administrator role

2. **Name conflicts (storage/AI Foundry)**:
   - Storage account names must be globally unique
   - Change `resourceToken` parameter in `infrastructure/main.parameters.json`
   - Try adding random suffix: `"stocktrading$(Get-Random -Maximum 999)"`

3. **RBAC assignment failures**:
   - Wait 2-3 minutes after identity creation
   - Re-run deployment (it's idempotent)
   - Verify permissions to create role assignments

4. **AI Foundry model deployment fails**:
   - Verify region supports AI Services
   - Check Cognitive Services quota
   - Ensure DeepSeek model available in your region

### Function App Issues

1. **Function not responding**:
   - Check logs: `az functionapp log tail --name function-mcpagent --resource-group AIFoundry.StockTrading.RG`
   - Verify functions listed in Azure Portal
   - Restart: `az functionapp restart --name function-mcpagent --resource-group AIFoundry.StockTrading.RG`

2. **Translation not working**:
   - Verify AI Foundry endpoint in app settings
   - Check managed identity has "Cognitive Services User" role
   - Test model deployment in portal → Deployments
   - Check Application Insights for errors

3. **Cold start performance**:
   - First request may take 2-5 seconds
   - Increase `instanceMemoryMB` to 4096 in parameters
   - Configure always-ready instances for production

### Power Platform Issues

1. **Agent import failures**:
   - Ensure Copilot Studio licenses available
   - Check solution dependencies
   - Verify environment version compatibility

2. **Agent communication issues**:
   - Verify connected agent configurations
   - Check MCP endpoint authentication
   - Test Function App endpoint accessibility
   - Review firewall rules

### Getting Help

- **Infrastructure**: See [infrastructure/README.md](infrastructure/README.md#troubleshooting)
- **Validation**: Run `.\infrastructure\validate.ps1`
- **Deployment Logs**: Azure Portal → Resource Group → Deployments
- **Function Logs**: Application Insights or `az functionapp log tail`

## Development

### Local Development Setup

```powershell
# Clone repository
git clone [repository-url]
cd MultiAgent-PM-2025

# Restore Function App dependencies
cd McpAzureFunction
dotnet restore

# Run locally
func start
```

### Testing

```powershell
# Test individual functions
# Navigate to http://localhost:7071/api/[function-name]

# Test MCP tools
# Use the MCP inspector or call endpoints directly
```

## Infrastructure Files

| File | Purpose | Documentation |
|------|---------|---------------|
| `infrastructure/main.bicep` | Complete infrastructure template | [Infrastructure README](infrastructure/README.md) |
| `infrastructure/main.parameters.json` | Configuration parameters | Customize for your environment |
| `infrastructure/deploy.ps1` | Automated deployment script | Run `.\deploy.ps1 -WhatIf` to preview |
| `infrastructure/validate.ps1` | Pre-deployment validation | Checks template and parameters |
| `infrastructure/README.md` | Detailed deployment guide | Step-by-step instructions |
| `infrastructure/DEPLOYMENT-SUMMARY.md` | Deployment overview | Resource details and costs |
| `infrastructure/PLAN-COMPARISON.md` | Hosting plan comparison | Flex Consumption vs others |

## Key Technologies

- **Azure Functions Flex Consumption** - Serverless compute with per-execution billing
- **AI Foundry (Cognitive Services)** - DeepSeek-V3.1 model deployment
- **Bicep** - Infrastructure-as-Code for Azure
- **Model Context Protocol (MCP)** - Tool exposure framework
- **.NET 8 Isolated Worker** - Modern Azure Functions runtime
- **Managed Identity** - Passwordless authentication
- **Application Insights** - Monitoring and diagnostics

## Contributing

When contributing to this repository:
1. Follow .NET coding standards for Azure Functions
2. Update Bicep templates for infrastructure changes
3. Test Bicep deployments with `validate.ps1` before committing
4. Follow Power Platform solution packaging best practices
5. Update documentation for any configuration changes

## License

[Specify your license here]

## Support

For issues and questions:
- **Infrastructure/Deployment**: See [infrastructure/README.md](infrastructure/README.md#troubleshooting)
- **Function App**: Check Application Insights logs
- **Power Platform**: Consult Copilot Studio documentation
- Azure Function issues: Check Azure Portal diagnostics
- Copilot Studio issues: Review Copilot Studio troubleshooting guides
- Integration issues: Verify MCP protocol implementation

## Version History

- **v1.0.0.1** - Initial release with 3-agent solution and MCP server