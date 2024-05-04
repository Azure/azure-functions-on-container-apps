using './index.bicep'

// Location to create the resources in.
param location = 'westcentralus'

// Set this param to unique value to get consistent resources everytime deployed.
// param prefix = ''

// set these flags to true to enable Vnet, and Vnet Internal.
param hasVnet = false
param isVnetInternal = false

