# cleanup.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName
)

Write-Host "=== Cleaning Up AI Loan Agent ===" -ForegroundColor Cyan
Write-Host "Resource Group: $ResourceGroupName"

# Confirm deletion
$confirm = Read-Host "`nThis will delete all resources. Continue? (y/n)"
if ($confirm -ne 'y') {
    Write-Host "Cleanup cancelled" -ForegroundColor Yellow
    exit
}

Write-Host "`nDeleting resource group..." -ForegroundColor Yellow
az group delete --name $ResourceGroupName --yes --no-wait

Write-Host "✓ Cleanup initiated" -ForegroundColor Green
Write-Host "Resource group deletion is running in the background." -ForegroundColor Gray
