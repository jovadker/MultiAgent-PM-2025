# MultiAgent-PM-2025

## Overview

This repository contains a multi-agent system for stock trading and portfolio management, built using Microsoft Copilot Studio and Azure Functions. The solution consists of:

1. **Azure Function App (MCP Server)** - A Model Context Protocol (MCP) server providing tools for mathematical operations and AI-powered translation
2. **Power Platform Solution** - A Copilot Studio solution with three interconnected agents for stock trading and portfolio management

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

1. **Azure Subscription** with permissions to create:
   - Function Apps
   - Azure OpenAI resources
   - Storage Accounts
   - Application Insights (optional)

2. **Power Platform Environment** with:
   - Copilot Studio license
   - Entra ID (Azure AD) integration
   - Power Automate access

3. **Development Tools**:
   - .NET 8.0 SDK
   - Azure Functions Core Tools
   - PowerShell 7+
   - Azure CLI

### Deployment Steps

#### Quick Start: Automated Infrastructure Deployment

**🚀 Fastest method using Bicep templates (5-10 minutes):**

```powershell
# Clone the repository
git clone <repository-url>
cd MultiAgent-PM-2025/infrastructure

# Run the automated deployment script
.\deploy.ps1

# Or deploy with Azure CLI
az login
az deployment group create `
  --resource-group AIFoundry.StockTrading.RG `
  --template-file main.bicep `
  --parameters main.parameters.json
```

**What gets deployed automatically:**
- ✅ Azure Function (Flex Consumption, .NET 8)
- ✅ AI Foundry with DeepSeek-V3.1 model
- ✅ Storage Account with deployment container
- ✅ Application Insights + Log Analytics
- ✅ Managed Identity with RBAC roles
- ✅ All configurations and settings

**📖 For detailed infrastructure documentation, see: [infrastructure/README.md](infrastructure/README.md)**

---

#### Alternative: Manual Deployment Steps

If you prefer step-by-step manual deployment:

#### Part 1: Deploy Azure Function to Flex Consumption

##### 1. Prepare Azure Resources

```powershell
# Login to Azure
az login --tenant 9b7dd4f7-a403-4500-afad-77b33b78b1d8

# Set variables
$resourceGroup = "AIFoundry.StockTrading.RG"
$location = "eastus"
$functionAppName = "function-mcpagent"
$storageAccountName = "stmcpagent$(Get-Random -Maximum 9999)"

# Create resource group (if not exists)
az group create --name $resourceGroup --location $location

# Create storage account
az storage account create `
  --name $storageAccountName `
  --resource-group $resourceGroup `
  --location $location `
  --sku Standard_LRS

# Create Function App with Flex Consumption plan
az functionapp create `
  --name $functionAppName `
  --resource-group $resourceGroup `
  --storage-account $storageAccountName `
  --runtime dotnet-isolated `
  --runtime-version 8 `
  --functions-version 4 `
  --os-type Windows `
  --consumption-plan-location $location
```

##### 2. Configure Azure OpenAI Access

```powershell
# Assign Managed Identity to Function App
az functionapp identity assign `
  --name $functionAppName `
  --resource-group $resourceGroup

# Get the Function App's Managed Identity ID
$principalId = (az functionapp identity show `
  --name $functionAppName `
  --resource-group $resourceGroup `
  --query principalId -o tsv)

# Assign Cognitive Services OpenAI User role to the Function App
# (Replace with your OpenAI resource details)
$openAIResourceId = "/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.CognitiveServices/accounts/{openai-name}"

az role assignment create `
  --assignee $principalId `
  --role "Cognitive Services OpenAI User" `
  --scope $openAIResourceId
```

##### 3. Build and Deploy Function App

```powershell
# Navigate to the function project directory
cd .\McpAzureFunction

# Build and publish
dotnet publish -c Release

# Deploy using the provided script
.\deploy-function.ps1 -ResourceGroup $resourceGroup -FunctionAppName $functionAppName

# Or use the main deployment script
.\deploy.ps1
```

##### 4. Configure Application Settings

```powershell
# Set Azure OpenAI configuration
az functionapp config appsettings set `
  --name $functionAppName `
  --resource-group $resourceGroup `
  --settings `
    AZURE_OPENAI_ENDPOINT="https://aifoundry-stocktrading.openai.azure.com" `
    AZURE_OPENAI_MODEL="DeepSeek-V3.1"
```

##### 5. Verify Deployment

```powershell
# Check function app status
az functionapp show `
  --name $functionAppName `
  --resource-group $resourceGroup `
  --query state

# List functions
az functionapp function list `
  --name $functionAppName `
  --resource-group $resourceGroup

# Get function app URL
az functionapp show `
  --name $functionAppName `
  --resource-group $resourceGroup `
  --query defaultHostName -o tsv
```

#### Part 2: Deploy to Power Platform / Copilot Studio

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

### Common Issues

1. **Function App not starting**:
   - Check storage account connection
   - Verify .NET 8.0 runtime is configured
   - Review Application Insights logs

2. **Translation not working**:
   - Verify Azure OpenAI endpoint and model deployment
   - Check Managed Identity has proper role assignment
   - Confirm DeepSeek-V3.1 model is deployed

3. **Agent import failures**:
   - Ensure environment has required licenses
   - Check for missing dependencies
   - Verify solution compatibility

4. **Agent communication issues**:
   - Verify connected agent configurations
   - Check authentication settings
   - Test individual agent endpoints

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

## Contributing

When contributing to this repository:
1. Follow .NET coding standards for Azure Functions
2. Follow Power Platform solution packaging best practices
3. Test locally before committing
4. Update documentation for any configuration changes

## License

[Specify your license here]

## Support

For issues and questions:
- Azure Function issues: Check Azure Portal diagnostics
- Copilot Studio issues: Review Copilot Studio troubleshooting guides
- Integration issues: Verify MCP protocol implementation

## Version History

- **v1.0.0.1** - Initial release with 3-agent solution and MCP server