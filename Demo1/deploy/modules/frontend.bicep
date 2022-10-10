param uniqueName string
param location string
param appInsightsName string
param workspaceName string
param sourceRepo string
param dockerFilePath string
param backendUrls array

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: appInsightsName
}

module arrayfix '../../../Common/deploy/modules/arrayfix.bicep' = {
  name: '${deployment().name}-frontendfix'
  params: {
    inputArray1:  [for backend in backendUrls: {
      name: backend.name
      value: '${backend.functionUrl}?code=${listkeys(backend.functionId, '2022-03-01').default}'
    }]
    inputArray2: [
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: appInsights.properties.ConnectionString
      }
    ]
  }
}

module frontend '../../../Common/deploy/frontend.bicep' = {
  name: '${deployment().name}-frontend'
  params: {
    location: location
    uniqueName: uniqueName
    appInsightsName: appInsightsName
    workspaceName: workspaceName
    dockerFilePath: dockerFilePath
    sourceRepo: sourceRepo
    envSettings: arrayfix.outputs.array
  }
}

output frontendUrl string = frontend.outputs.frontendUrl
