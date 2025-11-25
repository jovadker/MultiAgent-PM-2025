# Quick Deployment Script for Azure Infrastructure
# This script automates the deployment of the Multi-Agent Portfolio Management system

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "AIFoundry.StockTrading.RG",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory=$false)]
    [string]$Environment = "dev",
    
    [Parameter(Mandatory=$false)]
    [switch]$WhatIf,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipCodeDeploy
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Azure Infrastructure Deployment Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Azure CLI is installed
try {
    $azVersion = az version | ConvertFrom-Json
    Write-Host "✓ Azure CLI version: $($azVersion.'azure-cli')" -ForegroundColor Green
} catch {
    Write-Host "✗ Azure CLI is not installed. Please install from: https://aka.ms/installazurecli" -ForegroundColor Red
    exit 1
}

# Check if logged in
$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Host "Not logged in to Azure. Initiating login..." -ForegroundColor Yellow
    az login
    $account = az account show | ConvertFrom-Json
}

Write-Host "✓ Logged in as: $($account.user.name)" -ForegroundColor Green
Write-Host "✓ Subscription: $($account.name) ($($account.id))" -ForegroundColor Green
Write-Host ""

# Check if resource group exists, create if not
$rgExists = az group exists --name $ResourceGroupName
if ($rgExists -eq "false") {
    Write-Host "Creating resource group: $ResourceGroupName" -ForegroundColor Yellow
    az group create --name $ResourceGroupName --location $Location
    Write-Host "✓ Resource group created" -ForegroundColor Green
} else {
    Write-Host "✓ Resource group exists: $ResourceGroupName" -ForegroundColor Green
}
Write-Host ""

# Navigate to infrastructure directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# Run what-if analysis if requested
if ($WhatIf) {
    Write-Host "Running what-if analysis..." -ForegroundColor Yellow
    az deployment group what-if `
        --resource-group $ResourceGroupName `
        --template-file main.bicep `
        --parameters main.parameters.json `
        --parameters environment=$Environment
    
    Write-Host ""
    Write-Host "What-if analysis complete. No resources were deployed." -ForegroundColor Yellow
    exit 0
}

# Deploy infrastructure
Write-Host "Deploying infrastructure..." -ForegroundColor Yellow
Write-Host "This may take 5-10 minutes..." -ForegroundColor Yellow
Write-Host ""

$deploymentName = "mcpagent-deployment-$(Get-Date -Format 'yyyyMMddHHmmss')"

try {
    $deployment = az deployment group create `
        --name $deploymentName `
        --resource-group $ResourceGroupName `
        --template-file main.bicep `
        --parameters main.parameters.json `
        --parameters environment=$Environment `
        --output json | ConvertFrom-Json
    
    Write-Host ""
    Write-Host "✓ Infrastructure deployment completed successfully!" -ForegroundColor Green
    Write-Host ""
    
    # Display outputs
    Write-Host "Deployment Outputs:" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    $outputs = $deployment.properties.outputs
    
    foreach ($key in $outputs.Keys) {
        Write-Host "$key`: $($outputs[$key].value)" -ForegroundColor White
    }
    Write-Host ""
    
    $functionAppName = $outputs.functionAppName.value
    $functionAppUrl = $outputs.functionAppUrl.value
    
} catch {
    Write-Host ""
    Write-Host "✗ Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "To view detailed error logs:" -ForegroundColor Yellow
    Write-Host "az deployment group show --name $deploymentName --resource-group $ResourceGroupName" -ForegroundColor Yellow
    exit 1
}

# Deploy function code if not skipped
if (-not $SkipCodeDeploy) {
    Write-Host "Building and deploying function app code..." -ForegroundColor Yellow
    
    # Navigate to function app directory
    $functionDir = Join-Path (Split-Path -Parent $scriptDir) "McpAzureFunction"
    
    if (-not (Test-Path $functionDir)) {
        Write-Host "✗ Function app directory not found: $functionDir" -ForegroundColor Red
        Write-Host "Skipping code deployment." -ForegroundColor Yellow
    } else {
        Set-Location $functionDir
        
        # Build the project
        Write-Host "Building .NET project..." -ForegroundColor Yellow
        dotnet publish --configuration Release --output ./publish
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "✗ Build failed" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "✓ Build completed" -ForegroundColor Green
        
        # Create deployment package
        Write-Host "Creating deployment package..." -ForegroundColor Yellow
        Set-Location publish
        
        if (Test-Path "../released-package.zip") {
            Remove-Item "../released-package.zip" -Force
        }
        
        Compress-Archive -Path * -DestinationPath "../released-package.zip" -Force
        Set-Location ..
        
        Write-Host "✓ Deployment package created" -ForegroundColor Green
        
        # Deploy to Azure
        Write-Host "Deploying to Azure Functions..." -ForegroundColor Yellow
        az functionapp deployment source config-zip `
            --resource-group $ResourceGroupName `
            --name $functionAppName `
            --src released-package.zip
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "✗ Code deployment failed" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "✓ Code deployed successfully" -ForegroundColor Green
        
        # Cleanup
        Remove-Item publish -Recurse -Force
        Remove-Item released-package.zip -Force
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Function App URL: $functionAppUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Test the function app by navigating to the URL above" -ForegroundColor White
Write-Host "2. Configure Power Platform Copilot Studio to use the MCP endpoint" -ForegroundColor White
Write-Host "3. Monitor application logs in Application Insights" -ForegroundColor White
Write-Host ""
Write-Host "To view logs:" -ForegroundColor Yellow
Write-Host "az functionapp logs tail --name $functionAppName --resource-group $ResourceGroupName" -ForegroundColor White
Write-Host ""
