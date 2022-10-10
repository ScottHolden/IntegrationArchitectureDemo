param uniqueName string
param location string
param appInsightsName string

var backends = {
  backend1: loadTextContent('../src/backends/backend1.csx')
  backend2: loadTextContent('../src/backends/backend2.csx')
  backend3: loadTextContent('../src/backends/backend3.csx')
}
var backendList = items(backends)

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: appInsightsName
}

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

module functionApps 'modules/function.bicep' = [for backend in backendList: {
  name: '${deployment().name}-${backend.key}'
  params: {
    location: location
    backendName: backend.key
    functionName: '${uniqueName}-${backend.key}'
    functionPlanId: functionPlan.id
    functionSourceCode: backend.value
    instrumentationKey: appInsights.properties.InstrumentationKey
    storageAccountName: storageAccount.name
  }
}]

output backendUrls array = [for i in range(0, length(backendList)): {
  name: backendList[i].key
  functionUrl: functionApps[i].outputs.functionUrl
  functionId: functionApps[i].outputs.functionId
}]
