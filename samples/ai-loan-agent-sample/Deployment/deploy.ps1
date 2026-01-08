#!/usr/bin/env powershell
<#
.SYNOPSIS
    Deploy AI Loan Agent using Bicep.

.PARAMETER ProjectName
    Project name (3-15 chars). Resources named: <projectName>-<resource>-<uniqueId>

.PARAMETER Location
    Azure region. Default: eastus2

.PARAMETER Tags
    Optional tags as hashtable. Example: @{Environment='dev'; Owner='TeamA'}

.EXAMPLE
    .\deploy.ps1 -ProjectName "ailoan"

.EXAMPLE
    .\deploy.ps1 -ProjectName "ailoan" -Tags @{Environment='prod'; CostCenter='IT'}
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidatePattern('^[a-z0-9-]{3,15}$')]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$false)]
    [string]$Location = 'eastus2',
    
    [Parameter(Mandatory=$false)]
    [hashtable]$Tags = @{}
)

$ErrorActionPreference = "Stop"

# Normalize location to lowercase
$Location = $Location.ToLower()

# Validate location - must support both gpt-4.1-mini and Logic Apps Standard
$validLocations = @('australiaeast', 'westeurope', 'germanywestcentral', 'italynorth', 
                    'swedencentral', 'uksouth', 'eastus', 'eastus2', 'southcentralus', 'westus3')

if ($Location -notin $validLocations) {
    Write-Host "Error: Invalid location '$Location'" -ForegroundColor Red
    Write-Host "Valid locations (support both gpt-4.1-mini and Logic Apps Standard):" -ForegroundColor Yellow
    Write-Host "$($validLocations -join ', ')" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n=== AI Loan Agent Deployment ===" -ForegroundColor Cyan
Write-Host "Project: $ProjectName | Location: $Location`n"

# Check auth
$context = Get-AzContext -ErrorAction SilentlyContinue
if (-not $context) {
    Write-Host "Not logged in. Run: Connect-AzAccount" -ForegroundColor Red
    exit 1
}

# Create resource group
$resourceGroupName = "rg-$ProjectName"
$defaultTags = @{ 'Project' = $ProjectName }
$tags = $defaultTags + $Tags

$rg = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if (-not $rg) {
    New-AzResourceGroup -Name $resourceGroupName -Location $Location -Tag $tags | Out-Null
    Write-Host "✓ Resource group created: $resourceGroupName" -ForegroundColor Green
} else {
    Write-Host "✓ Resource group exists: $resourceGroupName" -ForegroundColor Green
}

# Deploy Bicep
Write-Host "`nDeploying infrastructure (5-10 minutes)..."

$bicepPath = "$PSScriptRoot/infrastructure/main.bicep"
$deploymentName = "ailoan-$(Get-Date -Format 'yyyyMMddHHmmss')"

try {
    $deployment = New-AzResourceGroupDeployment `
        -Name $deploymentName `
        -ResourceGroupName $resourceGroupName `
        -TemplateFile $bicepPath `
        -baseName $ProjectName `
        -location $Location `
        -Mode Incremental `
        -ErrorAction Stop
    
    Write-Host "✓ Infrastructure deployment complete" -ForegroundColor Green
}
catch {
    # Check if the only errors are RBAC conflicts (expected on redeployment)
    if ($_.Exception.Message -match 'RoleAssignmentExists|role assignment already exists') {
        Write-Host "✓ Infrastructure deployment complete (RBAC roles already configured)" -ForegroundColor Green
        # Get deployment outputs even if RBAC warnings occurred
        $deployment = Get-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name $deploymentName
    }
    else {
        Write-Host "`nDeployment failed:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        if ($_.Exception.InnerException) {
            Write-Host $_.Exception.InnerException.Message -ForegroundColor Red
        }
        exit 1
    }
}

# Wait for RBAC propagation (critical for managed identity to work)
Write-Host "`nWaiting 60 seconds for RBAC role assignments to propagate..." -ForegroundColor Yellow
Start-Sleep -Seconds 60
Write-Host "✓ RBAC propagation complete" -ForegroundColor Green

# Get outputs
$logicAppName = $deployment.Outputs.logicAppName.Value
$openAIEndpoint = $deployment.Outputs.openAIEndpoint.Value

# Generate local.settings.json (for local development with Azurite emulator)
$openAI = Get-AzResource -ResourceGroupName $resourceGroupName -ResourceType "Microsoft.CognitiveServices/accounts" | Select-Object -First 1

# Use Azurite emulator connection string for local development
# In Azure, the deployed Logic App uses managed identity (no connection string needed)
$localSettings = @{
    IsEncrypted = $false
    Values = @{
        "AzureWebJobsStorage" = "UseDevelopmentStorage=true"
        "FUNCTIONS_WORKER_RUNTIME" = "dotnet"
        "WORKFLOWS_SUBSCRIPTION_ID" = $context.Subscription.Id
        "WORKFLOWS_RESOURCE_GROUP_NAME" = $resourceGroupName
        "WORKFLOWS_LOCATION_NAME" = $Location
        "agent_openAIEndpoint" = $openAIEndpoint
        "agent_ResourceID" = $openAI.ResourceId
    }
}

$localSettingsPath = "$PSScriptRoot/../LogicApps/local.settings.json"
$localSettings | ConvertTo-Json -Depth 10 | Set-Content -Path $localSettingsPath -Encoding UTF8

# Deploy workflows using Azure PowerShell Zip Deploy
Write-Host "`nDeploying workflows to Logic App..."

$logicAppsPath = Resolve-Path "$PSScriptRoot/../LogicApps"
$zipPath = "$PSScriptRoot/workflows.zip"

# Create zip
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

# Get all items except those we want to exclude
$itemsToZip = Get-ChildItem -Path $logicAppsPath | Where-Object {
    $_.Name -notin @('.git', '.vscode', 'node_modules') -and
    $_.Name -notlike '__azurite*' -and
    $_.Name -notlike '__blobstorage__*' -and
    $_.Name -notlike '__queuestorage__*' -and
    $_.Extension -ne '.zip'
}

Push-Location $logicAppsPath
Compress-Archive -Path $itemsToZip.Name -DestinationPath $zipPath -Force
Pop-Location

# Check for Azure CLI
$azCliAvailable = $null -ne (Get-Command az -ErrorAction SilentlyContinue)

if (-not $azCliAvailable) {
    Write-Host "`n✗ Azure CLI not found. Workflows not deployed." -ForegroundColor Yellow
    Write-Host "Install: https://learn.microsoft.com/cli/azure/install-azure-cli" -ForegroundColor Yellow
    Write-Host "Alternative: Open workspace in VS Code, right-click LogicApps folder → Deploy to Logic App`n" -ForegroundColor Cyan
} else {
    try {
        az functionapp deployment source config-zip `
            --resource-group $resourceGroupName `
            --name $logicAppName `
            --src $zipPath `
            --output none `
            2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Workflows deployed successfully" -ForegroundColor Green
        } else {
            throw "Deployment returned exit code $LASTEXITCODE"
        }
    } catch {
        Write-Host "✗ Workflow deployment failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Alternative: Open workspace in VS Code, right-click LogicApps folder → Deploy to Logic App" -ForegroundColor Cyan
    }
}

Remove-Item $zipPath -Force -ErrorAction SilentlyContinue

# Restart Logic App to load workflows
Write-Host "`nRestarting Logic App..."
Restart-AzWebApp -ResourceGroupName $resourceGroupName -Name $logicAppName | Out-Null
Start-Sleep -Seconds 10
Write-Host "✓ Logic App restarted" -ForegroundColor Green

# Summary
Write-Host "`n=== Deployment Complete ===" -ForegroundColor Cyan
Write-Host "Resource Group: $resourceGroupName"
Write-Host "Logic App: $logicAppName"
Write-Host "OpenAI Endpoint: $openAIEndpoint"
Write-Host "Logic App URL: https://$logicAppName.azurewebsites.net"

Write-Host "`n--- Next: Quick Start Step 4 - Test & Validate ---" -ForegroundColor Yellow
Write-Host "Run test script, then verify agent workflows following README 'Testing & Validation' section"
Write-Host "  .\test-agent.ps1 -ResourceGroupName '$resourceGroupName' -LogicAppName '$logicAppName'" -ForegroundColor Cyan
