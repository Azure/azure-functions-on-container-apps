targetScope = 'subscription'

param dep_name string
param location string
param use_nfs_mount bool
param sub_path string
param use_read_only bool

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
    use_nfs_mount: use_nfs_mount
    sub_path: sub_path
    use_read_only: use_read_only
  }
}

