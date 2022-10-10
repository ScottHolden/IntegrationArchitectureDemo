param uniqueName string
param location string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: toLower(substring(uniqueName, 0, min(24, length(uniqueName))))
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
  }
}

resource functionPlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: uniqueName
  location: location
  kind: 'functionapp'
  sku: {
    name: 'Y1'
  }
  properties: {}
}

output functionPlanId string = functionPlan.id
output storageName string = storageAccount.name
