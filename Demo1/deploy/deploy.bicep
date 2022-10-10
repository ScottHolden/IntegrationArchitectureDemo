param prefix string = 'demo1'
param location string = resourceGroup().location
param sourceRepo string = 'https://github.com/ScottHolden/IntegrationArchitectureDemo.git'

var uniqueName = '${prefix}${uniqueString(prefix, resourceGroup().id, location)}'
var dockerFilePath = 'Demo1/src/Demo1/Dockerfile'

module appinsights '../../Common/deploy/modules/appinsights.bicep' = {
  name: '${deployment().name}-appinsights'
  params: {
    location: location
    uniqueName: uniqueName
  }
}

module backends '../../Common/deploy/backends.bicep' = {
  name: '${deployment().name}-backend'
  params: {
    location: location
    uniqueName: uniqueName
    appInsightsName: appinsights.outputs.appInsightsName
  }
}

module frontend 'modules/frontend.bicep' = {
  name: '${deployment().name}-fe'
  params: {
    location: location
    uniqueName: uniqueName
    appInsightsName: appinsights.outputs.appInsightsName
    workspaceName: appinsights.outputs.workspaceName
    dockerFilePath: dockerFilePath
    sourceRepo: sourceRepo
    backendUrls: backends.outputs.backendUrls
  }
}

output frontendUrl string = frontend.outputs.frontendUrl
