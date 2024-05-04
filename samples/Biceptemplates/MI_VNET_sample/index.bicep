targetScope = 'subscription'

param prefix string = newGuid()
param location string
param hasVnet bool
param isVnetInternal bool

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: '${prefix}-rg'
  location: location
}

module common 'common.bicep' = {
  name: 'common'
  scope: rg
  params: {
    prefix: prefix
    location: location
  }
}

module acaenv 'acaenv.bicep' = {
  name: 'acaenv'
  scope: rg
  params: {
    prefix: prefix
    location: location
    hasVnet: hasVnet
    isVnetInternal: isVnetInternal
  }
}

module functionapp 'functionapp.bicep' = {
  name: 'functionapp'
  scope: rg
  params: {
    prefix: prefix
    appLocation: location
    acrUrl: common.outputs.acrUrl
    storageName: common.outputs.storageName
    vaultUri: common.outputs.vaultUri
    identityResourceId: common.outputs.identityResourceId
    identityClientId: common.outputs.identityClientId
    envId: acaenv.outputs.envId
  }
}
