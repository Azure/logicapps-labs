// Storage Account Module - For Logic App runtime only

@description('Storage account name')
param storageAccountName string

@description('Location for the storage account')
param location string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false  // Enforce managed identity only - no connection strings or keys
  }
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output blobServiceUri string = storageAccount.properties.primaryEndpoints.blob
output queueServiceUri string = storageAccount.properties.primaryEndpoints.queue
output tableServiceUri string = storageAccount.properties.primaryEndpoints.table
