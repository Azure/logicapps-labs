#!/usr/bin/env powershell
<#
.SYNOPSIS
    Create ARM template and bundle LogicApps folder for 1-click deployment.

.DESCRIPTION
    This script prepares all necessary assets for 1-click deployment by performing two key tasks:

    1. Build ARM Template: Compiles the Bicep infrastructure file into an ARM template using the Bicep CLI.
    2. Bundle Workflows: Creates a deployment-ready workflows.zip containing all Logic App workflows.

    Automatically excludes development artifacts:
    - Version control (.git)
    - Editor settings (.vscode)
    - Dependencies (node_modules)
    - Local storage (__azurite*, __blobstorage__*, __queuestorage__*)
    - Existing zip files

.PARAMETER Sample
    Required. Name of the sample folder (e.g., "product-return-agent-sample").
    All paths are built from this parameter.

.EXAMPLE
    # From anywhere in the repository:
    .\samples\shared\scripts\BundleAssets.ps1 -Sample "product-return-agent-sample"

.EXAMPLE
    # From samples folder:
    .\shared\scripts\BundleAssets.ps1 -Sample "ai-loan-agent-sample"

.NOTES
    Requirements:
    - Bicep CLI must be installed
    - PowerShell 5.1 or later

    Expected folder structure:
    samples/your-sample/
    ├── Deployment/
    │   ├── main.bicep
    │   ├── sample-arm.json     # Generated
    │   └── workflows.zip       # Generated
    └── LogicApps/
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Sample
)

$ErrorActionPreference = "Stop"

# ============================================================================
# CONSTANTS
# ============================================================================

# Hardcoded upstream repository for URL generation
$upstreamRepo = "Azure/logicapps-labs"
$upstreamBranch = "main"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

Function New-MainBicepFromTemplate {
    <#
    .SYNOPSIS
        Generates main.bicep from template with placeholder replacement
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$TemplatePath,
        
        [Parameter(Mandatory = $true)]
        [string]$OutputPath,
        
        [Parameter(Mandatory = $true)]
        [string]$WorkflowsZipUrl
    )
    
    if (-not (Test-Path $TemplatePath)) {
        throw "Template file not found: $TemplatePath"
    }
    
    $template = Get-Content $TemplatePath -Raw
    $content = $template -replace '\{\{WORKFLOWS_ZIP_URL\}\}', $WorkflowsZipUrl
    
    $outputDir = Split-Path $OutputPath
    if (-not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }
    
    Set-Content -Path $OutputPath -Value $content -NoNewline
}

# ============================================================================
# BUILD PATHS FROM SAMPLE NAME
# ============================================================================

# Find repository root (contains samples/ folder)
$scriptDir = $PSScriptRoot
$repoRoot = $scriptDir
while ($repoRoot -and -not (Test-Path (Join-Path $repoRoot "samples"))) {
    $repoRoot = Split-Path $repoRoot -Parent
}

if (-not $repoRoot) {
    Write-Host "✗ Could not find repository root (looking for samples/ folder)" -ForegroundColor Red
    exit 1
}

# Build all paths from sample name
$sampleFolder = Join-Path $repoRoot "samples\$Sample"
$deploymentFolder = Join-Path $sampleFolder "Deployment"
$logicAppsFolder = Join-Path $sampleFolder "LogicApps"
$bicepPath = Join-Path $deploymentFolder "main.bicep"
$armTemplatePath = Join-Path $deploymentFolder "sample-arm.json"
$zipPath = Join-Path $deploymentFolder "workflows.zip"

# Get sample display name (convert folder name to title case)
$sampleDisplayName = ($Sample -replace '-sample$', '' -replace '-', ' ' | 
    ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) })

Write-Host "`n=== Bundling Assets for $sampleDisplayName ===" -ForegroundColor Cyan
Write-Host "Sample Folder: $sampleFolder" -ForegroundColor Gray
Write-Host "Deployment Folder: $deploymentFolder" -ForegroundColor Gray
Write-Host "LogicApps Folder: $logicAppsFolder" -ForegroundColor Gray

# Validate paths
if (-not (Test-Path $sampleFolder)) {
    Write-Host "✗ Sample folder not found: $sampleFolder" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $logicAppsFolder)) {
    Write-Host "✗ LogicApps folder not found: $logicAppsFolder" -ForegroundColor Red
    exit 1
}

# Ensure deployment directory exists
if (-not (Test-Path $deploymentFolder)) {
    New-Item -Path $deploymentFolder -ItemType Directory -Force | Out-Null
    Write-Host "✓ Created Deployment folder" -ForegroundColor Green
}

# ============================================================================
# TEMPLATE GENERATION: Create main.bicep if it doesn't exist
# ============================================================================

if (-not (Test-Path $bicepPath)) {
    Write-Host "`nGenerating main.bicep from template..." -ForegroundColor Cyan
    
    # Use hardcoded upstream repo for URL generation
    $workflowsUrl = "https://raw.githubusercontent.com/$upstreamRepo/$upstreamBranch/samples/$Sample/Deployment/workflows.zip"
    Write-Host "  Using: $upstreamRepo / $upstreamBranch" -ForegroundColor Gray
    
    # Use template from shared
    $templatePath = Join-Path $repoRoot "samples\shared\templates\main.bicep.template"
    
    if (-not (Test-Path $templatePath)) {
        Write-Host "✗ Template file not found: $templatePath" -ForegroundColor Red
        Write-Host "  Expected at: samples/shared/templates/main.bicep.template" -ForegroundColor Yellow
        exit 1
    }
    
    try {
        New-MainBicepFromTemplate -TemplatePath $templatePath -OutputPath $bicepPath -WorkflowsZipUrl $workflowsUrl
        Write-Host "  ✓ Created: main.bicep" -ForegroundColor Green
        Write-Host "  Location: $bicepPath" -ForegroundColor Gray
    } catch {
        Write-Host "✗ Failed to generate main.bicep: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "`nUsing existing main.bicep (not overwriting)" -ForegroundColor Cyan
    Write-Host "  Location: $bicepPath" -ForegroundColor Gray
}

# ============================================================================
# BUILD BICEP TO ARM TEMPLATE
# ============================================================================

Write-Host "`nBuilding ARM template from Bicep..." -ForegroundColor Cyan

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

# ============================================================================
# BUNDLE WORKFLOWS ZIP
# ============================================================================

Write-Host "`nBundling workflows.zip..." -ForegroundColor Cyan

# Remove existing zip if present
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
    Write-Host "✓ Removed existing workflows.zip" -ForegroundColor Green
}

# Get all items except those we want to exclude
$itemsToZip = Get-ChildItem -Path $logicAppsFolder | Where-Object {
    $_.Name -notin @('.git', '.vscode', 'node_modules') -and
    $_.Name -notlike '__azurite*' -and
    $_.Name -notlike '__blobstorage__*' -and
    $_.Name -notlike '__queuestorage__*' -and
    $_.Extension -ne '.zip'
}

Write-Host "`nIncluding files:"
$itemsToZip | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }

# Create zip
Push-Location $logicAppsFolder
try {
    Compress-Archive -Path $itemsToZip.Name -DestinationPath $zipPath -Force
} catch {
    Pop-Location
    Write-Host "`n✗ Failed to create workflows.zip: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
Pop-Location

if (Test-Path $zipPath) {
    $zipSize = (Get-Item $zipPath).Length / 1MB
    Write-Host "`n✓ Successfully created workflows.zip ($("{0:N2}" -f $zipSize) MB)" -ForegroundColor Green
    Write-Host "Location: $zipPath" -ForegroundColor Cyan
} else {
    Write-Host "`n✗ Failed to create workflows.zip" -ForegroundColor Red
    exit 1
}

# ============================================================================
# DEPLOY TO AZURE BUTTON
# ============================================================================

Write-Host "`n=== Deploy to Azure Button ===" -ForegroundColor Cyan

# Construct the URL to sample-arm.json using hardcoded upstream repo
$armUrl = "https://raw.githubusercontent.com/$upstreamRepo/$upstreamBranch/samples/$Sample/Deployment/sample-arm.json"

# URL encode for Azure Portal
$encodedUrl = [System.Uri]::EscapeDataString($armUrl)
$portalUrl = "https://portal.azure.com/#create/Microsoft.Template/uri/$encodedUrl"
$badgeUrl = "https://aka.ms/deploytoazurebutton"

Write-Host "Repository: $upstreamRepo" -ForegroundColor Gray
Write-Host "Branch: $upstreamBranch" -ForegroundColor Gray
Write-Host "ARM URL: $armUrl" -ForegroundColor Gray
Write-Host "`nAdd this to your README.md:" -ForegroundColor Cyan
Write-Host "[![Deploy to Azure]($badgeUrl)]($portalUrl)" -ForegroundColor Green

# ============================================================================
# SUMMARY
# ============================================================================

Write-Host "`n=== Bundling Complete ===" -ForegroundColor Cyan
Write-Host "Sample: $sampleDisplayName" -ForegroundColor Gray
Write-Host "ARM Template: $armTemplatePath" -ForegroundColor Gray
Write-Host "Workflows Zip: $zipPath" -ForegroundColor Gray
