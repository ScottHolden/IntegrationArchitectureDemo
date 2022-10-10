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

module baseasp 'modules/baseasp.bicep' = {
  name: '${deployment().name}-asp'
  params: {
    location: location
    uniqueName: uniqueName
  }
}

module functionApps 'modules/function.bicep' = [for backend in backendList: {
  name: '${deployment().name}-${backend.key}'
  params: {
    location: location
    backendName: backend.key
    functionName: '${uniqueName}-${backend.key}'
    functionPlanId: baseasp.outputs.functionPlanId
    functionSourceCode: backend.value
    instrumentationKey: appInsights.properties.InstrumentationKey
    storageAccountName: baseasp.outputs.storageName
  }
}]

output backendUrls array = [for i in range(0, length(backendList)): {
  name: backendList[i].key
  functionUrl: functionApps[i].outputs.functionUrl
  functionId: functionApps[i].outputs.functionId
}]
