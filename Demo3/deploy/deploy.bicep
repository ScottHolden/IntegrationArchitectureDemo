param prefix string = 'demo3'
param location string = resourceGroup().location
param sourceRepo string = 'https://github.com/ScottHolden/IntegrationArchitectureDemo.git'

var uniqueName = '${prefix}${uniqueString(prefix, resourceGroup().id, location)}'
var dockerFilePath = 'Demo3/src/Demo3/Dockerfile'

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

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: uniqueName
  location: location
  properties: {}
  sku: {
    name: 'Standard'
  }
  resource topic 'topics@2022-01-01-preview' = {
    name: 'addressUpdateEvent'
    properties: {}
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
    envSettings: [
      {
        name: 'sb-namespace'
        value: serviceBus.properties.serviceBusEndpoint
      }
      {
        name: 'sb-queue'
        value: serviceBus::topic.name
      }
    ]
  }
}

resource sbSenderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39' // Azure Service Bus Data Sender
}

resource senderRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  scope: serviceBus::topic
  name: guid(resourceGroup().id, uniqueName, sbSenderRoleDefinition.id)
  properties: {
    roleDefinitionId: sbSenderRoleDefinition.id
    principalId: frontend.outputs.containerAppPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output frontendUrl string = frontend.outputs.defaultDomain
