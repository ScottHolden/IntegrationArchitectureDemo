param uniqueName string
param location string
param instrumentationKey string
param workspaceName string
param sourceRepo string
param dockerFilePath string
param backendUrls array

module frontend '../../../Common/deploy/frontend.bicep' = {
  name: '${deployment().name}-frontend'
  params: {
    location: location
    uniqueName: uniqueName
    instrumentationKey: instrumentationKey// appinsights.outputs.instrumentationKey
    workspaceName: workspaceName// appinsights.outputs.workspaceName
    dockerFilePath: dockerFilePath
    sourceRepo: sourceRepo
    envSettings: [for backend in backendUrls: {
      name: backend.name
      value: '${backend.functionUrl}?code=${listkeys(backend.functionId, '2022-03-01').default}'
    }]
  }
}

output frontendUrl string = frontend.outputs.frontendUrl
