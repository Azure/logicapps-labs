// AI Loan Agent - Azure Infrastructure as Code
// Deploys Logic Apps Standard with Azure OpenAI for autonomous loan decisions
// Uses managed identity exclusively (no secrets/connection strings)

targetScope = 'resourceGroup'

@description('Base name used for the resources that will be deployed')
param baseName string

// uniqueSuffix for when we need unique values
var uniqueSuffix = uniqueString(resourceGroup().id)

// User-Assigned Managed Identity for Logic App → Storage authentication
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${baseName}-uami'
  location: resourceGroup().location
}

// Storage Account for workflow runtime
module storage 'modules/storage.bicep' = {
  name: 'storage-deployment'
  params: {
    storageAccountName: toLower(take(replace('${baseName}${uniqueSuffix}', '-', ''), 24))
    location: resourceGroup().location
  }
}

// Azure OpenAI with gpt-4.1-mini model
module openai 'modules/openai.bicep' = {
  name: 'openai-deployment'
  params: {
    openAIName: '${baseName}-openai'
    location: resourceGroup().location
  }
}

// Logic Apps Standard with dual managed identities
module logicApp 'modules/logicapp.bicep' = {
  name: 'logicapp-deployment'
  params: {
    logicAppName: '${baseName}-logicapp'
    location: resourceGroup().location
    storageAccountName: storage.outputs.storageAccountName
    openAIEndpoint: openai.outputs.endpoint
    openAIResourceId: openai.outputs.resourceId
    managedIdentityId: userAssignedIdentity.id
  }
}

// RBAC: Logic App → Storage (Blob, Queue, Table Contributor roles)
// dependsOn ensures RBAC is assigned after all resources exist (important for incremental deployments)
module storageRbac 'modules/storage-rbac.bicep' = {
  name: 'storage-rbac-deployment'
  params: {
    storageAccountName: storage.outputs.storageAccountName
    logicAppPrincipalId: userAssignedIdentity.properties.principalId
  }
  dependsOn: [
    storage
    userAssignedIdentity
    logicApp
  ]
}

// RBAC: Logic App → Azure OpenAI (Cognitive Services User role)
// dependsOn ensures RBAC is assigned after all resources exist (important for incremental deployments)
module openaiRbac 'modules/openai-rbac.bicep' = {
  name: 'openai-rbac-deployment'
  params: {
    openAIName: openai.outputs.name
    logicAppPrincipalId: logicApp.outputs.systemAssignedPrincipalId
  }
  dependsOn: [
    openai
    logicApp
  ]
}

// RBAC: Deployment Identity → Logic App (Website Contributor role for deployment)
module deploymentIdentityRbac 'modules/deployment-identity-rbac.bicep' = {
  name: 'deployment-identity-rbac'
  params: {
    deploymentIdentityPrincipalId: userAssignedIdentity.properties.principalId
  }
  dependsOn: [
    logicApp
    userAssignedIdentity
  ]
}

// Deploy workflows.zip to Logic App using Azure CLI
resource workflowDeploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: '${baseName}-deploy-workflows'
  location: resourceGroup().location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    azCliVersion: '2.59.0'
    retentionInterval: 'PT1H'
    timeout: 'PT30M'
    cleanupPreference: 'OnSuccess'
    environmentVariables: [
      {
        name: 'LOGIC_APP_NAME'
        value: logicApp.outputs.name
      }
      {
        name: 'RESOURCE_GROUP'
        value: resourceGroup().name
      }
      {
        name: 'WORKFLOWS_ZIP_URL'
        value: 'https://github.com/petehauge/logicapps-labs/raw/refs/heads/one-click-deploy/samples/ai-loan-agent-sample/Deployment/infrastructure/temp/workflows.zip'
      }
    ]
    scriptContent: '''
      #!/bin/bash
      set -e
      
      echo "Downloading workflows.zip..."
      wget -O workflows.zip "$WORKFLOWS_ZIP_URL"
      
      echo "Deploying workflows to Logic App: $LOGIC_APP_NAME"
      az functionapp deployment source config-zip \
        --resource-group "$RESOURCE_GROUP" \
        --name "$LOGIC_APP_NAME" \
        --src workflows.zip
      
      echo "Deployment completed successfully"
    '''
  }
  dependsOn: [
    storageRbac
    openaiRbac
    deploymentIdentityRbac
  ]
}

// Outputs
output logicAppName string = logicApp.outputs.name
output openAIEndpoint string = openai.outputs.endpoint
