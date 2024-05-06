param appName string
param appLocation string
param acrUrl string

resource functionapp 'Microsoft.Web/sites@2023-01-01' = {
  name: appName
  location: appLocation
  kind: 'functionapp,linux,container,azurecontainerapps'
  properties: {
    siteConfig: {
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/azure-functions/dotnet8-quickstart-demo:1.0'
      acrUseManagedIdentityCreds: true
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: acrUrl
        }
      ]
    }
  }
}
