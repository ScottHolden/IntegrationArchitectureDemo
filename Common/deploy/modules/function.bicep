param location string
param backendName string
param functionName string
param functionPlanId string
param storageAccountName string
param instrumentationKey string
param functionSourceCode string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: functionPlanId
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: instrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${instrumentationKey}'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
      ]
    }
    httpsOnly: true
  }
  resource backendFunction 'functions@2022-03-01' = {
    name: backendName
    properties: {
      config: {
        bindings: [
          {
            authLevel: 'function'
            name: 'req'
            type: 'httpTrigger'
            direction: 'in'
            methods: [
              'get'
              'post'
            ]
          }
          {
            name: '$return'
            type: 'http'
            direction: 'out'
          }
        ]
      }
      files: {
        'run.csx': functionSourceCode
      }
    }
  }
}

output functionId string = functionApp::backendFunction.id
output functionUrl string = 'https://${functionApp.properties.defaultHostName}/api/${functionApp::backendFunction.name}'
