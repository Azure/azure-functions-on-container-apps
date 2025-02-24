targetScope = 'subscription'

param prefix string = 'vinfunc${newGuid()}'
param location string
param hasVnet bool = false
param isVnetInternal bool = false
param useSystemIdentity bool = false

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
    createUMI: !useSystemIdentity
  }
}

module roleassignments 'roleassignments.bicep' = if (!useSystemIdentity) {
  name: 'roleassignments'
  scope: rg
  params: {
    prefix: prefix
    principalId: common.outputs.identityPrincipalId
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

module containerapp 'aca.bicep' = {
  name: 'containerapp'
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
    useSystemIdentity: useSystemIdentity
  }
}
