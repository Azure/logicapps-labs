#!/usr/bin/env powershell
<#
.SYNOPSIS
    Create ARM template for 1-click deploy and bundle LogicApps folder into workflows.zip for deployment.

.DESCRIPTION
    This script prepares all necessary assets for 1-click deployment by performing two key tasks:
    
    1. Build ARM Template: Compiles the Bicep infrastructure file (../Deployment/infrastructure/main.bicep)
       into an ARM template (sample-arm.json) using the Bicep CLI. This template defines all Azure 
       resources including Logic App Standard, Azure OpenAI, Storage Account, and Application Insights.
    
    2. Bundle Workflows: Creates a deployment-ready workflows.zip containing all Logic App workflows 
       and configuration from the ../LogicApps folder. Automatically excludes development artifacts:
       - Version control (.git)
       - Editor settings (.vscode)
       - Dependencies (node_modules)
       - Local storage (__azurite*, __blobstorage__*, __queuestorage__*)
       - Existing zip files
    
    Both outputs (sample-arm.json and workflows.zip) are created in the current directory for use
    in Azure Portal 1-click deployment scenarios.

.EXAMPLE
    .\BundleAssets.ps1
    
    Builds the ARM template and creates workflows.zip in the current directory.

.NOTES
    Requirements:
    - Bicep CLI must be installed (https://learn.microsoft.com/azure/azure-resource-manager/bicep/install)
    - PowerShell 5.1 or later
#>

$ErrorActionPreference = "Stop"

Write-Host "`n=== Bundling Logic App Assets ===" -ForegroundColor Cyan

# Paths relative to this script location
$logicAppsPath = Resolve-Path "$PSScriptRoot\..\LogicApps"
$zipPath = "$PSScriptRoot\workflows.zip"
$bicepPath = "$PSScriptRoot\..\Deployment\infrastructure\main.bicep"
$armTemplatePath = "$PSScriptRoot\sample-arm.json"

# Build Bicep to ARM template
Write-Host "`nBuilding ARM template from Bicep..."

if (-not (Test-Path $bicepPath)) {
    Write-Host "✗ Bicep file not found: $bicepPath" -ForegroundColor Red
    exit 1
}

# Check for Bicep CLI
$bicepAvailable = $null -ne (Get-Command bicep -ErrorAction SilentlyContinue)

if (-not $bicepAvailable) {
    Write-Host "✗ Bicep CLI not found. Please install it first." -ForegroundColor Red
    Write-Host "Install: https://learn.microsoft.com/azure/azure-resource-manager/bicep/install" -ForegroundColor Yellow
    exit 1
}

try {
    bicep build $bicepPath --outfile $armTemplatePath
    
    if (Test-Path $armTemplatePath) {
        $armSize = (Get-Item $armTemplatePath).Length / 1KB
        Write-Host "✓ Successfully created sample-arm.json ($("{0:N2}" -f $armSize) KB)" -ForegroundColor Green
    } else {
        throw "ARM template file was not created"
    }
} catch {
    Write-Host "✗ Failed to build ARM template: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Remove existing zip if present
if (Test-Path $zipPath) { 
    Remove-Item $zipPath -Force 
    Write-Host "✓ Removed existing workflows.zip" -ForegroundColor Green
}

# Get all items except those we want to exclude
$itemsToZip = Get-ChildItem -Path $logicAppsPath | Where-Object {
    $_.Name -notin @('.git', '.vscode', 'node_modules') -and
    $_.Name -notlike '__azurite*' -and
    $_.Name -notlike '__blobstorage__*' -and
    $_.Name -notlike '__queuestorage__*' -and
    $_.Extension -ne '.zip'
}

Write-Host "`nIncluding files:"
$itemsToZip | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }

# Create zip
Push-Location $logicAppsPath
Compress-Archive -Path $itemsToZip.Name -DestinationPath $zipPath -Force
Pop-Location

if (Test-Path $zipPath) {
    $zipSize = (Get-Item $zipPath).Length / 1MB
    Write-Host "`n✓ Successfully created workflows.zip ($("{0:N2}" -f $zipSize) MB)" -ForegroundColor Green
    Write-Host "Location: $zipPath" -ForegroundColor Cyan
} else {
    Write-Host "`n✗ Failed to create workflows.zip" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Bundling Complete ===" -ForegroundColor Cyan
Write-Host "ARM Template: $armTemplatePath" -ForegroundColor Gray
Write-Host "Workflows Zip: $zipPath" -ForegroundColor Gray
