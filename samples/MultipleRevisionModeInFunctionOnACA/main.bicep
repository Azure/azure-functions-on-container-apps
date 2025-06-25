@description('The name of the container app.')
param containerAppName string

@description('The name of the managed environment to which to deploy the container app.')
param environmentName string

@description('The name of the common user-assigned managed identity.')
param commonUserIdentityName string

@description('The name of the functionapp user-assigned managed identity.')
param functionAppUserIdentityName string

@description('Name of the ACR that has the container image.')
param containerRegistryName string

@description('Container image version tag.')
param containerImageVersion string

@description('Revision mode - must be Multiple for traffic splitting.')
param revisionMode string = 'Multiple'

@description('Container image version tag.')
param ingressExternal bool = true

@description('The region where to deploy the resources.')
param region string = resourceGroup().location

param workloadProfile string = ''

@allowed(['ignore', 'accept', 'require'])
param clientCertificateMode string = 'ignore'

@description('The first storage account used by the HTTP trigger function app.')
param httpStorageAccountName string

@description('The second storage account used by the Queue trigger function app.')
param queueStorageAccountName string

@description('Secret value for revision one (HTTP trigger).')
@secure()
param revisionOneSecretValue string

@description('Secret value for revision two (Queue trigger).')
@secure()
param revisionTwoSecretValue string

param tags object = {}

var containerRegistryServer = '${containerRegistryName}.azurecr.io'

resource commonIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = {
  name: commonUserIdentityName
}

resource functionAppIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = {
  name: functionAppUserIdentityName
}

resource environment 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: environmentName
}

// Step 1: First deployment - HTTP Trigger app only
resource initialContainerApp 'Microsoft.App/containerApps@2024-10-02-preview' = {
  kind: 'functionapp'
  name: containerAppName
  location: region
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${commonIdentity.id}': {}
      '${functionAppIdentity.id}': {}
    }
  }
  properties: {
    environmentId: environment.id
    workloadProfileName: empty(workloadProfile) ? null : workloadProfile
    configuration: {
      activeRevisionsMode: revisionMode
      ingress: {
        external: ingressExternal
        transport: 'auto'
        targetPort: 80
        clientCertificateMode: clientCertificateMode
        // No traffic configuration yet - will be added after both revisions exist
      }
      registries: [
        {
          identity: commonIdentity.id
          server: containerRegistryServer
        }
      ]
      secrets: [
        {
          name: 'revision-one-secret'
          value: revisionOneSecretValue
        }
        {
          name: 'revision-two-secret'
          value: revisionTwoSecretValue
        }
      ]
    }
    template: {
      revisionSuffix: 'http-revision'
      containers: [
        {
          name: 'httpcontainer'
          image: '${containerRegistryServer}/functionshttptriggertestapp:${containerImageVersion}'
          probes: [
            {
              type: 'Startup'
              httpGet: {
                path: '/api/HttpTriggerExample'
                port: 80
              }
              initialDelaySeconds: 5
              successThreshold: 1
              failureThreshold: 5
              timeoutSeconds: 5
              periodSeconds: 5
            }
            {
              type: 'Readiness'
              httpGet: {
                path: '/api/HttpTriggerExample'
                port: 80
              }
              initialDelaySeconds: 1
              successThreshold: 1
              failureThreshold: 3
              timeoutSeconds: 5
              periodSeconds: 10
            }
            {
              type: 'Liveness'
              httpGet: {
                path: '/api/HttpTriggerExample'
                port: 80
              }
              initialDelaySeconds: 1
              successThreshold: 1
              failureThreshold: 3
              timeoutSeconds: 5
              periodSeconds: 10
            }
          ]
          env: [
            {
              name: 'AzureWebJobsStorage__accountName'
              value: httpStorageAccountName
            }
            {
              name: 'AzureWebJobsStorage__clientId'
              value: functionAppIdentity.properties.clientId
            }
            {
              name: 'AzureWebJobsStorage__credential'
              value: 'managedidentity'
            }
            {
              name: 'FUNCTIONS_WORKER_RUNTIME'
              value: 'dotnet-isolated'
            }
            {
              name: 'HTTP_REVISION_SECRET'
              secretRef: 'revision-one-secret'
            }
          ]
          resources: {
            cpu: '0.5'
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
}