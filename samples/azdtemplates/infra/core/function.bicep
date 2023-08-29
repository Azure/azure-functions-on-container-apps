
//@minLength(1)
//@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('The image name for the api service')
param apiImageName string = ''


// Generate a unique token to be used in naming resources.
// Remove linter suppression after using.
#disable-next-line no-unused-vars
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))


#disable-next-line no-unused-vars
var apiServiceName = 'function-onaca'

var prefix = '${environmentName}-${resourceToken}' 



resource azStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${toLower(take(replace(prefix, '-', ''), 17))}storage'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
var azStorageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${azStorageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${azStorageAccount.listKeys().keys[0].value}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: 'log-${resourceToken}'
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

resource applicationInsightsResources 'Microsoft.Insights/components@2020-02-02' = {
  name: 'applicationinsights-${resourceToken}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'   
    WorkspaceResourceId: logAnalyticsWorkspace.id
    IngestionMode: 'LogAnalytics'
  }
}


resource environment 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name: '${take(prefix,4)}-containerapps-env'
  location: location
  properties: {}
}

resource azfunctionapp 'Microsoft.Web/sites@2022-09-01' = {
  name: 'funcapp-${take(resourceToken,4)}'
  location: location
  kind: 'functionapp'
  properties: {
    managedEnvironmentId: environment.id
    //name: '${prefix}-funcapp'
    siteConfig: {
      linuxFxVersion: 'DOCKER|${apiImageName}'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: azStorageConnectionString
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsightsResources.properties.InstrumentationKey
        }
      ]
    }
  }
}






// Add outputs from the deployment here, if needed.
//
// This allows the outputs to be referenced by other bicep deployments in the deployment pipeline,
// or by the local machine as a way to reference created resources in Azure for local development.
// Secrets should not be added here.
//
// Outputs are automatically saved in the local azd environment .env file.
// To see these outputs, run `azd env get-values`,  or `azd env get-values --output json` for json output.
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output functionAppName string = azfunctionapp.name
