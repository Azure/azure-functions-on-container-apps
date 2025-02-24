param appName string
param appLocation string
param acrUrl string
param envId string
param identityInfo object
param envVars object[]

resource containerApp 'Microsoft.App/containerApps@2024-02-02-preview' = {
  name: appName
  kind: 'functionapp'
  location: appLocation
  identity: identityInfo
  properties: {
    managedEnvironmentId: envId
    configuration: {
      registries:  [
        {
          server: acrUrl
          identity: 'system'
        }
      ]
      ingress:{
        external: true
        targetPort: 80
      }
    }
    template: {
      containers: [
        {
          image: 'mcr.microsoft.com/azure-functions/dotnet8-quickstart-demo:1.0'
          name: 'function-container'
          env: envVars
          resources: {
            cpu: 1
            memory: '2Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
  }
}
