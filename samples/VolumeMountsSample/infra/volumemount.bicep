param suffix string

var storageAccountName = 'storage${suffix}'
var fileShareName = 'fileshare'
var location = resourceGroup().location

@description('Storage account for volume mounts and function app')
resource storage 'Microsoft.Storage/storageAccounts@2023-04-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource service 'Microsoft.Storage/storageAccounts/fileServices@2023-04-01' = {
  parent: storage
  name: 'default'
}

resource share 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-04-01' = {
  parent: service
  name: fileShareName
}


@description('Log Analytics workspace for ACA env')
resource logws 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'logws${suffix}'
  location: 'centralus'
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}


@description('ACA env with volume mounts')
resource env 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: 'env${suffix}'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logws.properties.customerId
        sharedKey: logws.listKeys().primarySharedKey
      }
    }
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'consumption'
      }
      {
        name: 'd4'
        workloadProfileType: 'D4'
        minimumCount: 1
        maximumCount: 3
      }
    ]
  }
  resource env_storage 'storages@2023-05-01' = {
    name: 'smbstore'
    properties: {
      azureFile: {
        accessMode: 'ReadWrite'
        accountKey: storage.listKeys().keys[0].value
        accountName: storage.name
        shareName: fileShareName
      }
    }
  }
}

@description('Identity for all operations')
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'identity${suffix}'
  location: location
}


resource storageBlobDataOwnerRoleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
}

resource storageBlobDataOwnerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(suffix, storageBlobDataOwnerRoleDef.id)
  properties: {
    roleDefinitionId: storageBlobDataOwnerRoleDef.id
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}


@description('Function app with volume mounts support')
resource functionapp 'Microsoft.Web/sites@2023-01-01' = {
  dependsOn: [
    storageBlobDataOwnerRoleAssignment
  ]
  name: 'funcvolmnt-${suffix}'
  location: location
  kind: 'functionapp,linux,container,azurecontainerapps'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: env.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/azure-functions/dotnet8-quickstart-demo:1.0'
      minimumElasticInstanceCount: 1
      functionAppScaleLimit: 5
			azureStorageAccounts: {
					volumesmb: {
							accountName: 'smbstore'
							mountPath: '/mount-path'
							protocol: 'Smb'
							type: 'AzureFiles'
					}
			}
      appSettings: [
        {
            name: 'AzureWebJobsStorage__credential'
            value: 'managedidentity'
        }
        {
            name: 'AzureWebJobsStorage__clientId'
            value: identity.properties.clientId
        }
        {
            name: 'AzureWebJobsStorage__accountName'
            value: storage.name
        }
      ]
    }
  }
}
