#!/usr/bin/env powershell
<#
.SYNOPSIS
    Clean up AI Loan Agent resources by deleting the resource group.

.PARAMETER ResourceGroupName
    Name of the resource group to delete

.EXAMPLE
    .\cleanup.ps1 -ResourceGroupName "rg-ailoan"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName
)

$ErrorActionPreference = "Stop"

Write-Host "`n=== Cleaning Up AI Loan Agent ===" -ForegroundColor Cyan
Write-Host "Resource Group: $ResourceGroupName"

# Check auth
$context = Get-AzContext -ErrorAction SilentlyContinue
if (-not $context) {
    Write-Host "Not logged in. Run: Connect-AzAccount" -ForegroundColor Red
    exit 1
}

# Verify resource group exists
$rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if (-not $rg) {
    Write-Host "Resource group '$ResourceGroupName' not found" -ForegroundColor Red
    exit 1
}

# Confirm deletion
$confirm = Read-Host "`nThis will delete all resources in '$ResourceGroupName'. Continue? (y/n)"
if ($confirm -ne 'y') {
    Write-Host "Cleanup cancelled" -ForegroundColor Yellow
    exit
}

Write-Host "`nDeleting resource group..." -ForegroundColor Yellow
Remove-AzResourceGroup -Name $ResourceGroupName -Force -AsJob | Out-Null

Write-Host "✓ Cleanup initiated" -ForegroundColor Green
Write-Host "Resource group deletion is running in the background." -ForegroundColor Gray
