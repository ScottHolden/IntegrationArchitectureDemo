param uniqueName string
param location string
param appInsightsName string
param workspaceName string
param sourceRepo string
param dockerFilePath string
param envSettings array = []

var name = 'frontend'
var imageName = '${uniqueName}/${name}:v8'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: uniqueName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: false
  }
}

resource buildTask 'Microsoft.ContainerRegistry/registries/taskRuns@2019-06-01-preview' = {
  name: uniqueString(imageName)
  parent: containerRegistry
  properties: {
    runRequest: {
      type: 'DockerBuildRequest'
      dockerFilePath: dockerFilePath
      imageNames: [
        imageName
      ]
      isPushEnabled: true
      sourceLocation: sourceRepo
      platform: {
        os: 'Linux'
        architecture: 'amd64'
      }
      agentConfiguration: {
        cpu: 2
      }
    }
  }
}

resource containerPullIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: '${uniqueName}-containerpull'
  location: location
}

resource containerPullRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d' // ACR Pull
}

resource containerPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(uniqueName, containerPullIdentity.id, containerPullRoleDefinition.id)
  properties: {
    principalId: containerPullIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: containerPullRoleDefinition.id
  }
}

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  name: workspaceName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: appInsightsName
}

resource containerAppsEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' = {
  name: uniqueName
  location: location
  properties: {
    daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: workspace.properties.customerId
        sharedKey: workspace.listKeys().primarySharedKey
      }
    }
  }
}

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: name
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
      }
      registries: [
        {
          server: containerRegistry.properties.loginServer
          identity: containerPullIdentity.id
        }
      ]
    }
    template: {
      containers: [
        {
          name: name
          image: '${containerRegistry.properties.loginServer}/${imageName}'
          env: concat([
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: appInsights.properties.ConnectionString
            }
          ], envSettings)
          resources: {
            cpu: any('0.25')
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
  }
  identity: {
    type: 'SystemAssigned,UserAssigned'
    userAssignedIdentities: {
      '${containerPullIdentity.id}': {}
    }
  }
  dependsOn: [
    buildTask
    containerPullRoleAssignment
  ]
}

output frontendUrl string = containerApp.properties.configuration.ingress.fqdn
output containerAppId string = containerApp.id
output containerAppPrincipalId string = containerApp.identity.principalId
