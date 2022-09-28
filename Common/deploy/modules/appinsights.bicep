param uniqueName string
param location string

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: uniqueName
  location: location
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: uniqueName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspace.id
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output instrumentationKey string = appInsights.properties.InstrumentationKey
output workspaceName string = workspace.name
