# Azure Function Deployment Script for AIAgent.MCPServer
# Usage:
#   .\deploy-function.ps1 -ResourceGroup <resource-group> -FunctionAppName <function-app-name> [-Location <location>] [-StorageAccount <storage-account>]
# Or from another script:
#   & .\deploy-function.ps1 -ResourceGroup $resourceGroup -FunctionAppName $functionAppName

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroup,
    [Parameter(Mandatory=$true)]
    [string]$FunctionAppName)

$projectPath = ".\"
$publishFolder = "$projectPath\bin\Release\net8.0\publish"
$zipPath = "$projectPath\publish.zip"

Write-Host "Building and publishing the function..." -ForegroundColor Yellow
dotnet publish $projectPath -c Release

Push-Location $publishFolder
Compress-Archive -Path * -DestinationPath "..\..\function-app.zip" -Force
Pop-Location

Write-Host "Zipping published output..." -ForegroundColor Yellow

if (Test-Path $zipPath) { Remove-Item $zipPath }
Compress-Archive -Path $publishFolder\* -DestinationPath $zipPath

Write-Host "Deploying to Azure Function App $FunctionAppName in resource group $ResourceGroup..." -ForegroundColor Cyan
az functionapp deployment source config-zip --resource-group $ResourceGroup --name $FunctionAppName --src $zipPath

Write-Host "Deployment complete." -ForegroundColor Green
