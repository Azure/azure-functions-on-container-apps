

// The main bicep module to provision Azure resources.
// For a more complete walkthrough to understand how this file works with azd,
// see https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/make-azd-compatible?pivots=azd-create

//@minLength(1)
//@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('The image name for the create order service')
param apiImageNameCO string = ''

@description('The image name for the Http front end service')
param apiImageNameHP string = ''


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


// Create blob service for DAPR component
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2019-06-01' = {
  name: 'default'
  parent: azStorageAccount
}

// Create container for DAPR component
resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: 'daprblob'
  parent: blobService
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}

//Create Log Analytic Workspace
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

//Create AppInsights instance
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

 
// Add resources to be provisioned below.
// A full example that leverages azd bicep modules can be seen in the todo-python-mongo template:
// https://github.com/Azure-Samples/todo-python-mongo/tree/main/infra



resource environment 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name: '${take(prefix,4)}-containerapps-env'
  location: location
  properties: {
    daprAIInstrumentationKey: applicationInsightsResources.properties.InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

/* ###################################################################### */
// Setup Dapr componet Blob state store in ACA
/* ###################################################################### */
resource daprComponentStateManagement 'Microsoft.App/managedEnvironments/daprComponents@2023-05-01' = {
  parent: environment
  name: 'statestore'
  properties: {
    componentType: 'state.azure.blobstorage'
    version: 'v1'
    metadata: [
      {
        name: 'accountName'
        value: azStorageAccount.name
      }
      {
        name: 'accountKey'
        value: azStorageAccount.listKeys().keys[0].value
      }
      {
        name: 'containerName'
        value: container.name
      }
    ]
    scopes: []
  }
}

//Create Azure Functions Resource
resource azfunctionappCO 'Microsoft.Web/sites@2022-09-01' = {
  name: 'co-${take(resourceToken,4)}'
  location: location
  kind: 'functionapp'
  properties: {
    managedEnvironmentId: environment.id
    //name: '${prefix}-funcapp'
    siteConfig: {
      linuxFxVersion: 'DOCKER|${apiImageNameCO}'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: azStorageConnectionString
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsightsResources.properties.InstrumentationKey
        }

        {
          name: 'StateStoreName'
          value: 'statestore'
        }
        {
          name: 'PYTHON_ISOLATE_WORKER_DEPENDENCIES'
          value: '1'
        }
        {
          name: 'AzureWebJobsFeatureFlags'
          value: 'EnableWorkerIndexing'
        }
       
      ]
    }
    DaprConfig: {
      enabled: true
      appId: 'funcorderapp'
      appPort: 3001
      httpReadBufferSize: ''
      httpMaxRequestSize: ''
      logLevel: ''
      enableApiLogging: true
    }
  }
  dependsOn: [
    daprComponentStateManagement
  ]
}


resource azfunctionappHttpfront 'Microsoft.Web/sites@2022-09-01' = {
  name: 'hf-${take(resourceToken,4)}'
  location: location
  kind: 'functionapp'
  properties: {
    managedEnvironmentId: environment.id
    //name: '${prefix}-funcapp'
    siteConfig: {
      linuxFxVersion: 'DOCKER|${apiImageNameHP}'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: azStorageConnectionString
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsightsResources.properties.InstrumentationKey
        }

        {
          name: 'PYTHON_ISOLATE_WORKER_DEPENDENCIES'
          value: '1'
        }
        {
          name: 'AzureWebJobsFeatureFlags'
          value: 'EnableWorkerIndexing'
        }
        {
          name: 'Appid'
          value: 'funcorderapp'
        }
        {
          name: 'methodname'
          value: 'CreateOrder'
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
output functionAppName string = azfunctionappCO.name

