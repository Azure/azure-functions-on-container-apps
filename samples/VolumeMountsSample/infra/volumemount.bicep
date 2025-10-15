param suffix string
param use_nfs_mount bool
param sub_path string
param use_read_only bool

var storageAccountName = 'storage${suffix}'
var nfsStorageAccountName = 'nfsstorage${suffix}'
var fileShareName = 'fileshare'

var vnetName = 'vnet${suffix}'
var subnetName = 'subnet${suffix}'

var location = resourceGroup().location

var smbstoreName = 'smbstore'
var nfsstoreName = 'nfsstore'

var smb_volume = {
  accountName: smbstoreName
  mountPath: '/mount-path'
  protocol: 'Smb'
  type: 'AzureFiles'
  shareName: sub_path
}

var nfs_volume = {
  accountName: nfsstoreName
  mountPath: '/mount-path'
  protocol: 'Nfs'
  type: 'AzureFiles'
  shareName: sub_path
}

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

@description('VNET for ACA env when using Nfs volume mounts')
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/23'
          serviceEndpoints: [
            {
              locations: [location]
              service: 'Microsoft.Storage'
            }
          ]
          delegations: [
            {
              name: 'Microsoft.App/environments'
              properties: {
                serviceName: 'Microsoft.App/environments'
              }
            }
          ]
        }
      }
    ]
  }
}

@description('NFS storage account for volume mounts')
resource nfsstorage 'Microsoft.Storage/storageAccounts@2023-04-01' = if (use_nfs_mount) {
  name: nfsStorageAccountName
  location: location
  kind: 'FileStorage'
  sku: {
    name: 'Premium_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: false
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: '${vnet.id}/subnets/${subnetName}'
          action: 'Allow'
        }
      ]
      defaultAction: 'Deny'
    }
  }
}

resource nfsservice 'Microsoft.Storage/storageAccounts/fileServices@2023-04-01' = if (use_nfs_mount) {
  parent: nfsstorage
  name: 'default'
}

resource nfsshare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-04-01' = if (use_nfs_mount) {
  parent: nfsservice
  name: fileShareName
  properties: {
    accessTier: 'Premium'
    enabledProtocols: 'NFS'
    rootSquash: 'NoRootSquash'
    shareQuota: 1024
  }
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

@description('ACA env with smb volume mounts')
resource smbenv 'Microsoft.App/managedEnvironments@2023-05-01' = if (!use_nfs_mount) {
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
    name: smbstoreName
    properties: {
      azureFile: {
        accessMode: use_read_only ? 'ReadOnly' : 'ReadWrite'
        accountKey: storage.listKeys().keys[0].value
        accountName: storage.name
        shareName: fileShareName
      }
    }
  }
}

@description('ACA env with nfs volume mounts')
resource nfsenv 'Microsoft.App/managedEnvironments@2023-05-01' = if (use_nfs_mount) {
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
    vnetConfiguration: {
      infrastructureSubnetId: vnet.properties.subnets[0].id
      internal: false
    }
  }

  resource env_nfs_storage 'storages@2023-11-02-preview' = {
    name: nfsstoreName
    properties: {
      nfsAzureFile: {
        accessMode: use_read_only ? 'ReadOnly' : 'ReadWrite'
        server: '${nfsStorageAccountName}.file.core.windows.net'
        shareName: '/${nfsStorageAccountName}/${fileShareName}'
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
    managedEnvironmentId: use_nfs_mount ? nfsenv.id : smbenv.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/k8se/quickstart-functions:latest'
      minimumElasticInstanceCount: 1
      functionAppScaleLimit: 5
      azureStorageAccounts: {
        storagevolume: use_nfs_mount ? nfs_volume : smb_volume
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
