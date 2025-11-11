// AI Loan Agent - Azure Infrastructure as Code
// Deploys Logic Apps Standard with Azure OpenAI for autonomous loan decisions
// Uses managed identity exclusively (no secrets/connection strings)

targetScope = 'resourceGroup'

@minLength(3)
@maxLength(15)
@description('Project name used for resource naming (alphanumeric and hyphens only)')
param baseName string

@allowed([
  'australiaeast'
  'westeurope'
  'germanywestcentral'
  'italynorth'
  'swedencentral'
  'uksouth'
  'eastus'
  'eastus2'
  'southcentralus'
  'westus3'
])
@description('Azure region (must support both GPT-4.1-mini and Logic Apps Standard)')
param location string = 'eastus2'

// Variables
var uniqueSuffix = uniqueString(resourceGroup().id)

// User-Assigned Managed Identity for Logic App → Storage authentication
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${baseName}-uami'
  location: location
}

// Storage Account for workflow runtime
module storage 'modules/storage.bicep' = {
  name: 'storage-deployment'
  params: {
    storageAccountName: toLower(take(replace('${baseName}${uniqueSuffix}', '-', ''), 24))
    location: location
  }
}

// Azure OpenAI with gpt-4.1-mini model
module openai 'modules/openai.bicep' = {
  name: 'openai-deployment'
  params: {
    openAIName: '${baseName}-openai'
    location: location
  }
}

// Logic Apps Standard with dual managed identities
module logicApp 'modules/logicapp.bicep' = {
  name: 'logicapp-deployment'
  params: {
    logicAppName: '${baseName}-logicapp'
    location: location
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

// Outputs
output logicAppName string = logicApp.outputs.name
output openAIEndpoint string = openai.outputs.endpoint
