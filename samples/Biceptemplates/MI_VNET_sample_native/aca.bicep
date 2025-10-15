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

var envVars = useSystemIdentity ? [
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
]

var registries = useSystemIdentity ? null: [
  {
    server: acrUrl
    identity: identityResourceId
  }
]

resource containerApp 'Microsoft.App/containerApps@2024-02-02-preview' = {
  name: 'func1-${uniqueString(prefix, subscription().id)}'
  kind: 'functionapp'
  location: appLocation
  identity: identityInfo
  properties: {
    managedEnvironmentId: envId
    configuration: {
      registries: registries
      ingress:{
        external: true
        targetPort: 80
      }
    }
    template: {
      containers: [
        {
          image: 'mcr.microsoft.com/k8se/quickstart-functions:latest'
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

output fqdn string = containerApp.properties.configuration.ingress.fqdn


module faroleassignments 'roleassignments.bicep' = if (useSystemIdentity) {
  name: 'faroleassignments'
  params: {
    prefix: prefix
    principalId: containerApp.identity.principalId
  }
}

output functionappName string = containerApp.name


// redeploy function app to set acr creds after role assignments are done for system identity.
module functionappAfterSI 'acaAfterSI.bicep' = if (useSystemIdentity){
  name: 'containerappAfterSI'
  params: {
    appLocation: appLocation
    appName: containerApp.name
    acrUrl: acrUrl
    envId: envId
    identityInfo: identityInfo
    envVars: envVars
  }
}
