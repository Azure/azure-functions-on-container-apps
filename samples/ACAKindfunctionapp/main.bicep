@description('Specifies the name of the functions container app.')
param functionsContainerAppName string = 'app-${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the container app environment.')
param containerAppEnvName string = 'env-${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the log analytics workspace.')
param containerAppLogAnalyticsName string = 'log-${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the storage account.')
param storageAccountName string = 'st${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the application insights.')
param appInsightsName string = functionsContainerAppName

@description('Specifies the location for all resources.')
param location string = resourceGroup().location

@description('Specifies the docker container image to deploy.')
param containerImage string = 'mcr.microsoft.com/k8se/quickstart-functions:latest'

@description('Specifies the container port.')
param targetPort int = 80

@description('Number of CPU cores the container can use. Can be with a maximum of two decimals.')
param cpuCore string = '0.5'

@description('Amount of memory (in gibibytes, GiB) allocated to the container up to 4GiB. Can be with a maximum of two decimals. Ratio with CPU cores must be equal to 2.')
param memorySize string = '1'

@description('Minimum number of replicas that will be deployed')
param minReplicas int = 1

@description('Maximum number of replicas that will be deployed')
param maxReplicas int = 3

@description('Specifies the Functions runtime')
param functionsRuntime string = 'dotnet-isolated'

@description('Create a log analytics workspace for the container app environment.')
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: containerAppLogAnalyticsName
  location: location
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}

@description('Create a container app environment.')
resource containerAppEnv 'Microsoft.App/managedEnvironments@2024-10-02-preview' = {
  name: containerAppEnvName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
    publicNetworkAccess: 'Enabled'
    workloadProfiles: [
        {
            name: 'Consumption'
            workloadProfileType: 'Consumption'
        }
    ]
  }
}

@description('Create a storage account for the function app.')
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

@description('Create an application insights resource for the function app.')
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

@description('Create a native functions container app.')
resource functionsContainerApp 'Microsoft.App/containerApps@2024-10-02-preview' = {
  name: functionsContainerAppName
  location: location
  kind: 'functionapp'
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: targetPort
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      secrets: [
        // **WARNING**
        // This sample uses connection strings to keep the template lightweight. For production scenarios, it's strongly recommended 
        // to use Managed Identity for improved security and operational best practices.
        {
          name: 'azurewebjobsstorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'appinsightsconnectionstring'
          value: appInsights.properties.ConnectionString
        }
      ]
    }
    template: {
      containers: [
        {
          name: functionsContainerAppName
          image: containerImage
          env: [
            {
              name: 'AzureWebJobsStorage'
              secretRef: 'azurewebjobsstorage'
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              secretRef: 'appinsightsconnectionstring'
            }
            {
              name: 'FUNCTIONS_WORKER_RUNTIME'
              value: functionsRuntime
            }
          ]
          resources: {
            cpu: json(cpuCore)
            memory: '${memorySize}Gi'
          }
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
      }
    }
  }
}

output functionsContainerAppId string = functionsContainerApp.id
output functionsContainerAppFQDN string = functionsContainerApp.properties.configuration.ingress.fqdn
