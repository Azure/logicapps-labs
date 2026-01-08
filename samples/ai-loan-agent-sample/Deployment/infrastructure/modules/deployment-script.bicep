// Deployment Script Module - Deploys workflows.zip to Logic App
// Includes RBAC assignment for deployment identity

@description('Location for the deployment script resource')
param location string

@description('Name for the deployment script resource')
param deploymentScriptName string

@description('User-assigned managed identity ID for deployment')
param userAssignedIdentityId string

@description('Principal ID of the user-assigned managed identity used for deployment')
param deploymentIdentityPrincipalId string

@description('Name of the Logic App to deploy to')
param logicAppName string

@description('Resource group name')
param resourceGroupName string

@description('URL to the workflows.zip file')
param workflowsZipUrl string

// Grant Website Contributor role at resource group level to deployment identity
// This allows the deployment script to deploy code to the Logic App and read the App Service Plan
resource websiteContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, deploymentIdentityPrincipalId, 'de139f84-1756-47ae-9be6-808fbbe84772')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'de139f84-1756-47ae-9be6-808fbbe84772') // Website Contributor
    principalId: deploymentIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Deploy workflows.zip to Logic App using Azure CLI
resource workflowDeploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: deploymentScriptName
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
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
        value: logicAppName
      }
      {
        name: 'RESOURCE_GROUP'
        value: resourceGroupName
      }
      {
        name: 'WORKFLOWS_ZIP_URL'
        value: workflowsZipUrl
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
      
      echo "Waiting 60 seconds for workflow registration and RBAC propagation..."
      sleep 60
      
      echo "Deployment completed successfully"
    '''
  }
  dependsOn: [
    websiteContributorRoleAssignment
  ]
}
