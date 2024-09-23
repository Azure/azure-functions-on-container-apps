targetScope = 'subscription'

param dep_name string
param location string

var suffix = uniqueString(dep_name, subscription().id)

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${dep_name}'
  location: location
}

module volumemount 'volumemount.bicep' = {
  name: 'volumemount-${suffix}'
  scope: rg
  params: {
    suffix: suffix
  }
}

