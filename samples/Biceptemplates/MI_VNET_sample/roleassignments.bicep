
param prefix string
param principalId string

// Role Definitions
resource acrPullRoleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
}

resource storageBlobDataOwnerRoleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
}

resource storageQueueDataReaderRoleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '19e7f393-937e-4f77-808e-94535e297925'
}

resource storageQueueProcessorRoleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '8a0f0c08-91a1-4084-bc3d-661d67233fed'
}

resource storageQueueContributorRoleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
}

resource storageQueueSenderRoleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'c6a89b2d-59bc-44d0-9896-0f6e12d7b80a'
}

resource keyVaultSecretOfficerRoleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
}

resource keyVaultSecretUserRoleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}


// Role Assignments
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(prefix, acrPullRoleDef.id)
  properties: {
    roleDefinitionId: acrPullRoleDef.id
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

resource storageBlobDataOwnerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(prefix, storageBlobDataOwnerRoleDef.id)
  properties: {
    roleDefinitionId: storageBlobDataOwnerRoleDef.id
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

resource storageQueueDataReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(prefix, storageQueueDataReaderRoleDef.id)
  properties: {
    roleDefinitionId: storageQueueDataReaderRoleDef.id
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

resource storageQueueProcessorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(prefix, storageQueueProcessorRoleDef.id)
  properties: {
    roleDefinitionId: storageQueueProcessorRoleDef.id
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

resource storageQueueContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(prefix, storageQueueContributorRoleDef.id)
  properties: {
    roleDefinitionId: storageQueueContributorRoleDef.id
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

resource storageQueueSenderignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(prefix, storageQueueSenderRoleDef.id)
  properties: {
    roleDefinitionId: storageQueueSenderRoleDef.id
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

resource keyVaultSecretOfficerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(prefix, keyVaultSecretOfficerRoleDef.id)
  properties: {
    roleDefinitionId: keyVaultSecretOfficerRoleDef.id
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

resource keyVaultSecretUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(prefix, keyVaultSecretUserRoleDef.id)
  properties: {
    roleDefinitionId: keyVaultSecretUserRoleDef.id
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
