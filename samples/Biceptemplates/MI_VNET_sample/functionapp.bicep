param prefix string
param appLocation string

param acrUrl string
param storageName string
param vaultUri string
param envId string
param identityResourceId string
param identityClientId string

resource functionapp 'Microsoft.Web/sites@2023-01-01' = {
  name: 'func1-${uniqueString(prefix, subscription().id)}'
  location: appLocation
  kind: 'functionapp,linux,container,azurecontainerapps'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityResourceId}': {}
    }
  }
  properties: {
    keyVaultReferenceIdentity: identityResourceId
    managedEnvironmentId: envId
    siteConfig: {
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/azure-functions/dotnet8-quickstart-demo:1.0'
      acrUseManagedIdentityCreds: true
      acrUserManagedIdentityID: identityResourceId
      minimumElasticInstanceCount: 1
      functionAppScaleLimit: 5
      appSettings: [
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
    }
  }
}
