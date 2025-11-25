# Bicep Infrastructure Validation Script
# This script validates the Bicep templates before deployment

param(
    [Parameter(Mandatory=$false)]
    [string]$TemplateFile = "main.bicep",
    
    [Parameter(Mandatory=$false)]
    [string]$ParametersFile = "main.parameters.json"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Bicep Template Validation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Change to script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# Check if Bicep CLI is installed
Write-Host "Checking Bicep CLI installation..." -ForegroundColor Yellow
try {
    $bicepVersion = az bicep version
    Write-Host "✓ Bicep CLI is installed: $bicepVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Bicep CLI not found. Installing..." -ForegroundColor Yellow
    az bicep install
    Write-Host "✓ Bicep CLI installed" -ForegroundColor Green
}
Write-Host ""

# Check if template file exists
if (-not (Test-Path $TemplateFile)) {
    Write-Host "✗ Template file not found: $TemplateFile" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Template file found: $TemplateFile" -ForegroundColor Green

# Check if parameters file exists
if (-not (Test-Path $ParametersFile)) {
    Write-Host "✗ Parameters file not found: $ParametersFile" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Parameters file found: $ParametersFile" -ForegroundColor Green
Write-Host ""

# Build Bicep template
Write-Host "Building Bicep template..." -ForegroundColor Yellow
try {
    az bicep build --file $TemplateFile --stdout > $null
    Write-Host "✓ Bicep template builds successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Bicep build failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Validate parameters file JSON
Write-Host "Validating parameters file..." -ForegroundColor Yellow
try {
    $params = Get-Content $ParametersFile | ConvertFrom-Json
    Write-Host "✓ Parameters file is valid JSON" -ForegroundColor Green
} catch {
    Write-Host "✗ Parameters file is invalid JSON: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Check required parameters
Write-Host "Checking required parameters..." -ForegroundColor Yellow
$requiredParams = @(
    "location",
    "functionAppRuntime",
    "functionAppRuntimeVersion",
    "functionAppName",
    "aiFoundryName"
)

$missingParams = @()
foreach ($param in $requiredParams) {
    if (-not $params.parameters.$param) {
        $missingParams += $param
    }
}

if ($missingParams.Count -gt 0) {
    Write-Host "✗ Missing required parameters:" -ForegroundColor Red
    $missingParams | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}
Write-Host "✓ All required parameters present" -ForegroundColor Green
Write-Host ""

# Validate specific parameter values
Write-Host "Validating parameter values..." -ForegroundColor Yellow

# Check location
$location = $params.parameters.location.value
$validLocations = @("eastus", "eastus2", "westus2", "westus3", "northeurope", "westeurope", "uksouth", "southeastasia")
if ($location -notin $validLocations) {
    Write-Host "⚠ Warning: Location '$location' may not support Flex Consumption plan" -ForegroundColor Yellow
    Write-Host "  Supported regions: $($validLocations -join ', ')" -ForegroundColor Yellow
} else {
    Write-Host "✓ Location '$location' supports Flex Consumption" -ForegroundColor Green
}

# Check runtime
$runtime = $params.parameters.functionAppRuntime.value
$validRuntimes = @("dotnet-isolated", "python", "java", "node", "powerShell")
if ($runtime -notin $validRuntimes) {
    Write-Host "✗ Invalid runtime: $runtime" -ForegroundColor Red
    Write-Host "  Valid runtimes: $($validRuntimes -join ', ')" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Runtime '$runtime' is valid" -ForegroundColor Green

# Check runtime version
$runtimeVersion = $params.parameters.functionAppRuntimeVersion.value
Write-Host "✓ Runtime version: $runtimeVersion" -ForegroundColor Green

# Check instance settings
$maxInstances = $params.parameters.maximumInstanceCount.value
if ($maxInstances -lt 40 -or $maxInstances -gt 1000) {
    Write-Host "✗ Invalid maximumInstanceCount: $maxInstances (must be 40-1000)" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Maximum instances: $maxInstances" -ForegroundColor Green

$instanceMemory = $params.parameters.instanceMemoryMB.value
if ($instanceMemory -ne 2048 -and $instanceMemory -ne 4096) {
    Write-Host "✗ Invalid instanceMemoryMB: $instanceMemory (must be 2048 or 4096)" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Instance memory: ${instanceMemory}MB" -ForegroundColor Green

Write-Host ""

# Check naming conflicts
Write-Host "Checking resource naming..." -ForegroundColor Yellow
$functionAppName = $params.parameters.functionAppName.value
$aiFoundryName = $params.parameters.aiFoundryName.value

if ($functionAppName.Length -lt 2 -or $functionAppName.Length -gt 60) {
    Write-Host "✗ Function app name length must be 2-60 characters" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Function app name: $functionAppName" -ForegroundColor Green

if ($aiFoundryName.Length -lt 2 -or $aiFoundryName.Length -gt 64) {
    Write-Host "✗ AI Foundry name length must be 2-64 characters" -ForegroundColor Red
    exit 1
}
Write-Host "✓ AI Foundry name: $aiFoundryName" -ForegroundColor Green

Write-Host ""

# Check Azure login status
Write-Host "Checking Azure login status..." -ForegroundColor Yellow
try {
    $account = az account show 2>$null | ConvertFrom-Json
    if ($account) {
        Write-Host "✓ Logged in as: $($account.user.name)" -ForegroundColor Green
        Write-Host "✓ Subscription: $($account.name)" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠ Not logged in to Azure" -ForegroundColor Yellow
    Write-Host "  Run 'az login' before deployment" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "✓ Validation Complete - No Errors" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Template is ready for deployment!" -ForegroundColor Cyan
Write-Host ""
Write-Host "To deploy:" -ForegroundColor Yellow
Write-Host "  .\deploy.ps1" -ForegroundColor White
Write-Host ""
Write-Host "To preview changes:" -ForegroundColor Yellow
Write-Host "  .\deploy.ps1 -WhatIf" -ForegroundColor White
Write-Host ""
