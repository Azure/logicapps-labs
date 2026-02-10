// Auto-generated from shared/templates/main.bicep.template
// To customize: edit this file directly or delete to regenerate from template
//
// Logic Apps Agent Sample - Azure Infrastructure as Code
// Deploys Logic Apps Standard with Azure OpenAI for autonomous agent workflows
// Uses managed identity exclusively (no secrets/connection strings)

targetScope = 'resourceGroup'

@description('Base name used for the resources that will be deployed (alphanumerics and hyphens only)')
@minLength(3)
@maxLength(60)
param BaseName string

// uniqueSuffix for when we need unique values
var uniqueSuffix = uniqueString(resourceGroup().id)

// URL to workflows.zip (replaced by BundleAssets.ps1 with https://raw.githubusercontent.com/Azure/logicapps-labs/main/samples/product-return-agent-sample/Deployment/workflows.zip)
var workflowsZipUrl = 'https://raw.githubusercontent.com/Azure/logicapps-labs/main/samples/product-return-agent-sample/Deployment/workflows.zip'

// User-Assigned Managed Identity for Logic App → Storage authentication
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${take(BaseName, 60)}-managedidentity'
  location: resourceGroup().location
}

// Storage Account for workflow runtime
module storage '../../shared/modules/storage.bicep' = {
  name: '${take(BaseName, 43)}-storage-deployment'
  params: {
    storageAccountName: toLower(take(replace('${take(BaseName, 16)}${uniqueSuffix}', '-', ''), 24))
    location: resourceGroup().location
  }
}

// Azure OpenAI with gpt-5-mini model
module openai '../../shared/modules/openai.bicep' = {
  name: '${take(BaseName, 44)}-openai-deployment'
  params: {
    openAIName: '${take(BaseName, 54)}-openai'
    location: resourceGroup().location
  }
}

// Logic Apps Standard with dual managed identities
module logicApp '../../shared/modules/logicapp.bicep' = {
  name: '${take(BaseName, 42)}-logicapp-deployment'
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
module storageRbac '../../shared/modules/storage-rbac.bicep' = {
  name: '${take(BaseName, 38)}-storage-rbac-deployment'
  params: {
    storageAccountName: storage.outputs.storageAccountName
    logicAppPrincipalId: userAssignedIdentity.properties.principalId
  }
  dependsOn: [
    logicApp
  ]
}

// RBAC: Logic App → Azure OpenAI (Cognitive Services User role)
module openaiRbac '../../shared/modules/openai-rbac.bicep' = {
  name: '${take(BaseName, 39)}-openai-rbac-deployment'
  params: {
    openAIName: openai.outputs.name
    logicAppPrincipalId: logicApp.outputs.systemAssignedPrincipalId
  }
}

// Deploy workflows using deployment script with RBAC
module workflowDeployment '../../shared/modules/deployment-script.bicep' = {
  name: '${take(BaseName, 42)}-workflow-deployment'
  params: {
    deploymentScriptName: '${BaseName}-deploy-workflows'
    location: resourceGroup().location
    userAssignedIdentityId: userAssignedIdentity.id
    deploymentIdentityPrincipalId: userAssignedIdentity.properties.principalId
    logicAppName: logicApp.outputs.name
    resourceGroupName: resourceGroup().name
    workflowsZipUrl: workflowsZipUrl
  }
  dependsOn: [
    storageRbac
    openaiRbac
  ]
}

// Outputs
output logicAppName string = logicApp.outputs.name
output openAIEndpoint string = openai.outputs.endpoint
