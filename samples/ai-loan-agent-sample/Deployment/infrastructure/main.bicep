// AI Loan Agent - Azure Infrastructure as Code
// Deploys Logic Apps Standard with Azure OpenAI for autonomous loan decisions
// Uses managed identity exclusively (no secrets/connection strings)

targetScope = 'resourceGroup'

@description('Base name used for the resources that will be deployed (alphanumerics and hyphens only)')
@minLength(3)
@maxLength(60)
param BaseName string

// uniqueSuffix for when we need unique values
var uniqueSuffix = uniqueString(resourceGroup().id)

// User-Assigned Managed Identity for Logic App → Storage authentication
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${take(BaseName, 60)}-managedidentity'
  location: resourceGroup().location
}

// Storage Account for workflow runtime
module storage 'modules/storage.bicep' = {
  name: '${BaseName}-storage-deployment'
  params: {
    storageAccountName: toLower(take(replace('${take(BaseName, 16)}${uniqueSuffix}', '-', ''), 24))
    location: resourceGroup().location
  }
}

// Azure OpenAI with gpt-4.1-mini model
module openai 'modules/openai.bicep' = {
  name: '${BaseName}-openai-deployment'
  params: {
    openAIName: '${take(BaseName, 54)}-openai'
    location: resourceGroup().location
  }
}

// Logic Apps Standard with dual managed identities
module logicApp 'modules/logicapp.bicep' = {
  name: '${BaseName}-logicapp-deployment'
  params: {
    logicAppName: '${take(BaseName, 22)}${uniqueSuffix}'
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
  name: '${BaseName}-storage-rbac-deployment'
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
  name: '${BaseName}-openai-rbac-deployment'
  params: {
    openAIName: openai.outputs.name
    logicAppPrincipalId: logicApp.outputs.systemAssignedPrincipalId
  }
  dependsOn: [
    openai
    logicApp
  ]
}

// Deploy workflows using deployment script with RBAC
module workflowDeployment 'modules/deployment-script.bicep' = {
  name: '${BaseName}-workflow-deployment'
  params: {
    deploymentScriptName: '${BaseName}-deploy-workflows'
    location: resourceGroup().location
    userAssignedIdentityId: userAssignedIdentity.id
    deploymentIdentityPrincipalId: userAssignedIdentity.properties.principalId
    logicAppName: logicApp.outputs.name
    resourceGroupName: resourceGroup().name
    workflowsZipUrl: 'https://github.com/modularity/logicapps-labs/releases/download/v1.0.1/workflows.zip'
  }
  dependsOn: [
    storageRbac
    openaiRbac
    logicApp
    userAssignedIdentity
  ]
}

// Outputs
output logicAppName string = logicApp.outputs.name
output openAIEndpoint string = openai.outputs.endpoint
