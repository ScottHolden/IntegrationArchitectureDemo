param prefix string = 'demo4'
param location string = resourceGroup().location

var uniqueName = '${prefix}${uniqueString(prefix, resourceGroup().id, location)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01'= {
  name: '${uniqueName}sa'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: '${uniqueName}-datafactory'
  location: location
}

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: '${uniqueName}-sqlServer'
  location: location
  properties:{
    administratorLogin:'sqladmin'
    administratorLoginPassword:'Password123!'
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: '${uniqueName}-sqldb'
  location: location
}
