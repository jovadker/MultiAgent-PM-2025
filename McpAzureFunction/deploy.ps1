

az login --tenant 9b7dd4f7-a403-4500-afad-77b33b78b1d8
$resourceGroup = "AIFoundry.StockTrading.RG"
$functionAppName = "function-mcpagent"

Write-Host ""
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "  Deploying Azure Function App" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""

.\deploy-function.ps1 -ResourceGroup $resourceGroup -FunctionAppName $functionAppName


