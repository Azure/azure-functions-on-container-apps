param location string = resourceGroup().location



@description('Resource name prefix')
param resourceNamePrefix string
var envResourceNamePrefix = toLower(resourceNamePrefix)

/* ###################################################################### */
// Create storage account for function app prereq
/* ###################################################################### */
resource azStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${envResourceNamePrefix}storage'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
var azStorageAccountPrimaryAccessKey = listKeys(azStorageAccount.id, azStorageAccount.apiVersion).keys[0].value

resource logAnalyticsWorkspace'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: '${envResourceNamePrefix}-la'
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${envResourceNamePrefix}-ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource environment 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name: '${envResourceNamePrefix}-env'
  location: location
  properties: {
    daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}
  

resource azfunctionapp 'Microsoft.Web/sites@2022-09-01' = {
  name: '${envResourceNamePrefix}-funcapp'
  location: location
  kind: 'functionapp'
  properties: {
    name: '${envResourceNamePrefix}-funcapp'
    managedEnvironmentId:environment.id
    siteConfig: {
    linuxFxVersion: 'Docker|mcr.microsoft.com/azure-functions/dotnet7-quickstart-demo:1.0'  
    appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: azStorageAccount.properties.ConnectionString
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
      ]

    }
    
  }
}

  
output functionAppName string = azfunctionapp.name
