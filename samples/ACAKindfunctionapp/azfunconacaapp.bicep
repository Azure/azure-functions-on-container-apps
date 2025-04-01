param containerapps_queuetestscale2_name string = 'queuetestscale2'
param managedEnvironments_scaletestenv1_externalid string = '/subscriptions/<subid>/resourceGroups/my-test-func-rg/providers/Microsoft.App/managedEnvironments/scaletestenv1'

resource containerapps_queuetestscale2_name_resource 'Microsoft.App/containerapps@2024-10-02-preview' = {
  name: containerapps_queuetestscale2_name
  location: 'East US'
  kind: 'functionapp'
  identity: {
    type: 'None'
  }
  properties: {
    managedEnvironmentId: managedEnvironments_scaletestenv1_externalid
    environmentId: managedEnvironments_scaletestenv1_externalid
    workloadProfileName: 'Consumption'
    configuration: {
      secrets: [
        {
          name: 'reg-pswd-ae5073ca-****'
        }
      ]
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 80
        exposedPort: 0
        transport: 'Auto'
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        allowInsecure: false
        stickySessions: {
          affinity: 'none'
        }
      }
      registries: [
        {
          server: 'queue******.azurecr.io'
          username: 'queue***acr'
          passwordSecretRef: 'reg-pswd-******-****'
        }
      ]
      identitySettings: []
      maxInactiveRevisions: 100
    }
    template: {
      containers: [
        {
          image: 'queu******.azurecr.io/queue*****testimg:v1'
          imageType: 'ContainerImage'
          name: containerapps_queuetestscale2_name
          env: [
            {
              name: 'AzureWebJobsSTORAGE_CONNECTION_STRING'
              value: '<Connection_String>'
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: '<connection_string>'
            }
            {
              name: 'AzureWebJobsStorage'
              value: '<Storage_connection_string>'
            }
          ]
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 2
        maxReplicas: 10
        cooldownPeriod: 300
        pollingInterval: 30
      }
    }
  }
}
