// Grant deployment identity permissions to deploy to Logic App

@description('Principal ID of the user-assigned managed identity used for deployment')
param deploymentIdentityPrincipalId string

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
