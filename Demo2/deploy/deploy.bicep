param prefix string = 'demo2'
param location string = resourceGroup().location
param sourceRepo string = 'https://github.com/ScottHolden/IntegrationArchitectureDemo.git'

var uniqueName = '${prefix}${uniqueString(prefix, resourceGroup().id, location)}'
var dockerFilePath = 'Demo2/src/Dockerfile'


resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: uniqueName
  location: location
  properties: {
    
  }
}

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
    instrumentationKey: appinsights.outputs.instrumentationKey
  }
}

module frontend '../../Common/deploy/frontend.bicep' = {
  name: '${deployment().name}-frontend'
  params: {
    location: location
    uniqueName: uniqueName
    instrumentationKey: appinsights.outputs.instrumentationKey
    workspaceName: appinsights.outputs.workspaceName
    dockerFilePath: dockerFilePath
    sourceRepo: sourceRepo
  }
}

output frontendUrl string = frontend.outputs.defaultDomain
