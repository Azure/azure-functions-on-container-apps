param prefix string
param appLocation string

param acrUrl string
param storageName string
param vaultUri string
param envId string
param identityResourceId string
param identityClientId string
param useSystemIdentity bool

var identityInfo = useSystemIdentity ? {
  type: 'SystemAssigned'
}: {
  type: 'UserAssigned'
  userAssignedIdentities: {
    '${identityResourceId}': {}
  }
}

var appsettings = useSystemIdentity ? [
  {
    name: 'DOCKER_REGISTRY_SERVER_URL'
    value: acrUrl
  }
  {
      name: 'AzureWebJobsStorage__accountName'
      value: storageName
  }
 /*  {
    name: 'keyVaultSecret'
    value: '@Microsoft.KeyVault(SecretUri=${vaultUri}secrets/mysecret)'
  } */
]: [
  {
    name: 'DOCKER_REGISTRY_SERVER_URL'
    value: acrUrl
  }
  {
      name: 'AzureWebJobsStorage__credential'
      value: 'managedidentity'
  }
  {
      name: 'AzureWebJobsStorage__clientId'
      value: identityClientId
  }
  {
      name: 'AzureWebJobsStorage__accountName'
      value: storageName
  }
  {
    name: 'keyVaultSecret'
    value: '@Microsoft.KeyVault(SecretUri=${vaultUri}secrets/mysecret)'
  }
]

resource functionapp 'Microsoft.Web/sites@2023-01-01' = {
  name: 'func1-${uniqueString(prefix, subscription().id)}'
  location: appLocation
  kind: 'functionapp,linux,container,azurecontainerapps'
  identity: identityInfo
  properties: {
    keyVaultReferenceIdentity: useSystemIdentity ? '': identityResourceId
    managedEnvironmentId: envId
    siteConfig: {
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/azure-functions/dotnet8-quickstart-demo:1.0'
      acrUseManagedIdentityCreds: !useSystemIdentity
      acrUserManagedIdentityID: useSystemIdentity ? '': identityResourceId
      minimumElasticInstanceCount: 1
      functionAppScaleLimit: 5
      appSettings: appsettings
    }
  }
}


module faroleassignments 'roleassignments.bicep' = if (useSystemIdentity) {
  name: 'faroleassignments'
  params: {
    prefix: prefix
    principalId: functionapp.identity.principalId
  }
}

output functionappName string = functionapp.name
