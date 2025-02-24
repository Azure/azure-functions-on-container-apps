param prefix string
param location string
param createUMI bool

@description('Host storage account')
resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'storage${uniqueString(prefix, subscription().id)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    allowBlobPublicAccess: false
  }
}

@description('Queue service')
resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2023-01-01' = {
  parent: storage
  name: 'default'
}

@description('Queue for queue trigger')
resource inputQueue 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-01-01' = {
  parent: queueService
  name: 'inputqueue'
}

@description('Queue for queue output binding')
resource outputQueue 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-01-01' = {
  parent: queueService
  name: 'outputqueue'
}


@description('Container registry for images')
resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: 'acr${uniqueString(prefix, subscription().id)}'
  location: location
  sku: {
    name: 'Basic'
  }
}

@description('Key vault for key vault references')
resource vault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: 'kv${uniqueString(prefix, subscription().id)}'
  location: location
  properties: {
    accessPolicies:[]
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: vault
  name: 'mysecret'
  properties: {
    value: 'Hello, World!'
  }
}

@description('Identity for all operations')
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = if(createUMI) {
  name: 'identity${uniqueString(prefix, subscription().id)}'
  location: location
}

output acrUrl string = acr.properties.loginServer
output storageName string = storage.name
output vaultUri string = vault.properties.vaultUri
output identityResourceId string = createUMI ? identity.id: ''
output identityClientId string = createUMI ? identity.properties.clientId: ''
output identityPrincipalId string = createUMI ? identity.properties.principalId: ''
