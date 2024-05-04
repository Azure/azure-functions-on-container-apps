param prefix string
param location string

@description('Host storage account')
resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'storage${uniqueString(prefix, subscription().id)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
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
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'identity${uniqueString(prefix, subscription().id)}'
  location: location
}

// Role Definitions
resource acrPullRoleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: acr
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
}

resource storageBlobDataOwnerRoleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: storage
  name: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
}

resource storageQueueDataReaderRoleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: storage
  name: '19e7f393-937e-4f77-808e-94535e297925'
}

resource storageQueueProcessorRoleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: storage
  name: '8a0f0c08-91a1-4084-bc3d-661d67233fed'
}

resource storageQueueContributorRoleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: storage
  name: '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
}

resource storageQueueSenderRoleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: storage
  name: 'c6a89b2d-59bc-44d0-9896-0f6e12d7b80a'
}

resource keyVaultSecretOfficerRoleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: vault
  name: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
}

resource keyVaultSecretUserRoleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: vault
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}

// Role Assignments
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(prefix, acrPullRoleDef.id)
  properties: {
    roleDefinitionId: acrPullRoleDef.id
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource storageBlobDataOwnerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(prefix, storageBlobDataOwnerRoleDef.id)
  properties: {
    roleDefinitionId: storageBlobDataOwnerRoleDef.id
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource storageQueueDataReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(prefix, storageQueueDataReaderRoleDef.id)
  properties: {
    roleDefinitionId: storageQueueDataReaderRoleDef.id
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource storageQueueProcessorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(prefix, storageQueueProcessorRoleDef.id)
  properties: {
    roleDefinitionId: storageQueueProcessorRoleDef.id
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource storageQueueContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(prefix, storageQueueContributorRoleDef.id)
  properties: {
    roleDefinitionId: storageQueueContributorRoleDef.id
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource storageQueueSenderignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(prefix, storageQueueSenderRoleDef.id)
  properties: {
    roleDefinitionId: storageQueueSenderRoleDef.id
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource keyVaultSecretOfficerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(prefix, keyVaultSecretOfficerRoleDef.id)
  properties: {
    roleDefinitionId: keyVaultSecretOfficerRoleDef.id
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource keyVaultSecretUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(prefix, keyVaultSecretUserRoleDef.id)
  properties: {
    roleDefinitionId: keyVaultSecretUserRoleDef.id
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}


output acrUrl string = acr.properties.loginServer
output storageName string = storage.name
output vaultUri string = vault.properties.vaultUri
output identityResourceId string = identity.id
output identityClientId string = identity.properties.clientId
