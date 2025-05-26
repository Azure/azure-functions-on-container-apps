param prefix string
param location string
param hasVnet bool
param isVnetInternal bool

@description('Log Analytics workspace for ACA env')
resource logws 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'logws${uniqueString(prefix, subscription().id)}'
  location: 'centralus'
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

@description('VNET for ACA env')
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet${uniqueString(prefix, subscription().id)}'
  location: location
  properties:{
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet${uniqueString(prefix, subscription().id)}'
        properties: {
          addressPrefix: '10.0.0.0/23'
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

@description('ACA env with vnet')
resource vNetEnv 'Microsoft.App/managedEnvironments@2023-05-01' = if (hasVnet) {
  name: 'vnetenv${uniqueString(prefix, subscription().id)}'
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
      internal: isVnetInternal
    }
  }
}

@description('ACA env without vnet')
resource env 'Microsoft.App/managedEnvironments@2023-05-01' = if (!hasVnet) {
  name: 'env${uniqueString(prefix, subscription().id)}'
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
}

output envId string = hasVnet ? vNetEnv.id : env.id
