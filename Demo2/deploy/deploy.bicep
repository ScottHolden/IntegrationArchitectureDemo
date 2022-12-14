param prefix string = 'demo2'
param location string = resourceGroup().location
param sourceRepo string = 'https://github.com/ScottHolden/IntegrationArchitectureDemo.git'

var uniqueName = '${prefix}${uniqueString(prefix, resourceGroup().id, location)}'
var dockerFilePath = 'Demo2/src/Demo2/Dockerfile'

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

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: uniqueName
  location: location
  properties: {}
  sku: {
    name: 'Standard'
  }
  resource queue 'queues@2022-01-01-preview' = {
    name: 'addressUpdates'
    properties: {}
  }
}

module backendUrls 'modules/backendurls.bicep' = {
  name: '${deployment().name}-beurls'
  params: {
    backends: backends.outputs.backendUrls
  }
}

module frontend '../../Common/deploy/frontend.bicep' = {
  name: '${deployment().name}-frontend'
  params: {
    location: location
    uniqueName: uniqueName
    appInsightsName: appinsights.outputs.appInsightsName
    workspaceName: appinsights.outputs.workspaceName
    dockerFilePath: dockerFilePath
    sourceRepo: sourceRepo
    envSettings: concat(backendUrls.outputs.backendUrls,[
      {
        name: 'sb-namespace'
        value: '${serviceBus.name}.servicebus.windows.net'
      }
      {
        name: 'sb-queue'
        value: serviceBus::queue.name
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: appinsights.outputs.connectionString
      }
    ])
  }
}

resource sbSenderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39' // Azure Service Bus Data Sender
}

resource senderRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  scope: serviceBus::queue
  name: guid(resourceGroup().id, uniqueName, sbSenderRoleDefinition.id)
  properties: {
    roleDefinitionId: sbSenderRoleDefinition.id
    principalId: frontend.outputs.containerAppPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource sbReaderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0' // Azure Service Bus Data Sender
}

resource readerRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  scope: serviceBus::queue
  name: guid(resourceGroup().id, uniqueName, sbReaderRoleDefinition.id)
  properties: {
    roleDefinitionId: sbReaderRoleDefinition.id
    principalId: frontend.outputs.containerAppPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output frontendUrl string = frontend.outputs.frontendUrl
