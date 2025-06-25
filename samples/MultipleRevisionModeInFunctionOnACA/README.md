# Multiple Revision Mode for Azure Functions on Container Apps - Best Practices Guide

This repository demonstrates how to implement **Multiple Revision Mode** for Azure Functions on Azure Container Apps (ACA) using best practices for enterprise deployments. Multiple revision mode enables advanced deployment patterns like blue-green deployments, A/B testing, and gradual traffic splitting between different versions of your functions.

---

## 1. Introduction

Azure Container Apps supports **Multiple Revision Mode** for native Azure Functions, allowing you to:
- Deploy multiple versions of your function app simultaneously
- Split traffic between different revisions for A/B testing
- Perform blue-green deployments with zero downtime
- Gradually migrate traffic from old to new versions
- Maintain revision-specific configurations and secrets

**Key Benefits:**
- **Zero-downtime deployments** - Deploy new versions without affecting live traffic
- **Safe rollbacks** - Instantly switch traffic back to previous working revision
- **Controlled rollouts** - Gradually increase traffic to new versions
- **A/B testing** - Compare performance between different implementations

**Official Documentation:**
- [Azure Container Apps Revisions](https://learn.microsoft.com/en-us/azure/container-apps/revisions)
- [Native Azure Functions on Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/functions-overview)
- [Traffic Splitting in Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/traffic-splitting)

---

## 2. Best Practices for Multiple Revision Mode

### 2.1 Storage Account Isolation

**✅ RECOMMENDED: Use separate storage accounts for each revision**

Each revision should have its own dedicated storage account to avoid:
- Resource contention between revisions
- Unexpected state sharing
- Deployment conflicts
- Performance degradation during traffic splitting

```bicep
// HTTP Trigger revision storage
param httpStorageAccountName string

// Queue Trigger revision storage  
param queueStorageAccountName string
```

**Why separate storage accounts?**
- **Isolation**: Prevents one revision from affecting another's performance
- **Security**: Each revision can have different access patterns and permissions
- **Monitoring**: Easier to track resource usage per revision
- **Scaling**: Independent scaling characteristics per revision

### 2.2 Revision-Specific Secrets Management

**✅ RECOMMENDED: Use revision-specific secrets unless they're truly shared**

```bicep
secrets: [
  {
    name: 'revision-one-secret'
    value: revisionOneSecretValue
  }
  {
    name: 'revision-two-secret'
    value: revisionTwoSecretValue
  }
  // Only add shared secrets that are truly common across all revisions
  {
    name: 'common-api-key'
    value: sharedApiKeyValue
  }
]
```

**Guidelines for Secret Management:**
- **Revision-specific**: Database connection strings, feature flags, revision-specific API keys
- **Shared**: Common external service keys, monitoring tokens, shared certificates
- **Security**: Use Azure Key Vault references for production secrets
- **Rotation**: Plan for independent secret rotation per revision



---

## 3. Deployment Strategy

### 3.1 Two-Phase Revision Creation

The deployment follows a **two-phase approach** for creating multiple revisions:

**Phase 1: Initial Container App Creation**
- Deploy the main.bicep template to create the first container app
- This automatically creates the first revision (HTTP trigger revision)
- The container app is configured with `activeRevisionsMode: 'Multiple'`
- Initial revision becomes active and receives 100% of traffic

**Phase 2: Second Revision Creation**
- After the initial deployment, create the second revision using Azure Portal or CLI
- The second revision can have different configuration, container image, or environment variables
- Configure traffic splitting between the two revisions

### 3.2 Creating Additional Revisions

**Option 1: Using Azure Portal**
1. Navigate to your Container App in the Azure Portal
2. Go to "Revisions and replicas" section
3. Click "Create new revision"
4. Modify configuration as needed (container image, environment variables, secrets)
5. Deploy the new revision
6. Configure traffic splitting in the "Ingress" section

**Option 2: Using Azure CLI**
```powershell
# Create a new revision with different configuration
az containerapp revision copy --name "my-function-app" --resource-group $RESOURCE_GROUP --revision-suffix "queue-revision"

# Update the new revision with different settings
az containerapp update --name "my-function-app" --resource-group $RESOURCE_GROUP --revision-suffix "queue-revision" --set-env-vars "AzureWebJobsStorage__accountName=queuestorage001" "QUEUE_REVISION_SECRET=secretRef:revision-two-secret"

# Configure traffic splitting
az containerapp ingress traffic set --name "my-function-app" --resource-group $RESOURCE_GROUP --revision-weight "my-function-app--http-revision=80" "my-function-app--queue-revision=20"
```

### 3.3 Traffic Management

```bicep
// After both revisions are deployed, configure traffic splitting
traffic: [
  {
    revisionName: '${containerAppName}--http-revision'
    weight: 80  // 80% traffic to stable revision
  }
  {
    revisionName: '${containerAppName}--queue-revision'
    weight: 20  // 20% traffic to new revision
  }
]
```

### 3.3 Monitoring and Observability

**✅ Implement comprehensive monitoring**
- Enable Application Insights for each revision
- Set up custom metrics for business KPIs
- Configure alerts for error rates and performance
- Use Log Analytics for centralized logging

---

## 4. Main.bicep Template Configuration

The `main.bicep` template creates the initial container app with the following key configurations:

### 4.1 Required Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `containerAppName` | string | Name of the container app | `my-function-app` |
| `environmentName` | string | Name of the Container Apps environment | `my-aca-env` |
| `commonUserIdentityName` | string | User-assigned managed identity for shared resources | `common-identity` |
| `functionAppUserIdentityName` | string | User-assigned managed identity for function app | `function-identity` |
| `containerRegistryName` | string | Azure Container Registry name | `myregistry` |
| `containerImageVersion` | string | Container image tag | `latest` |
| `httpStorageAccountName` | string | Storage account for HTTP trigger revision | `httpstorage001` |
| `queueStorageAccountName` | string | Storage account for Queue trigger revision | `queuestorage001` |
| `revisionOneSecretValue` | securestring | Secret value for first revision | `http-secret-value` |
| `revisionTwoSecretValue` | securestring | Secret value for second revision | `queue-secret-value` |

### 4.2 Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `revisionMode` | string | `'Multiple'` | Revision mode for the container app |
| `ingressExternal` | bool | `true` | Whether ingress is external |
| `region` | string | `resourceGroup().location` | Deployment region |
| `workloadProfile` | string | `''` | Workload profile name (empty for Consumption) |
| `clientCertificateMode` | string | `'ignore'` | Client certificate mode |
| `tags` | object | `{}` | Resource tags |

### 4.3 Template Features

**Initial Revision Configuration:**
- Creates the first revision with suffix `http-revision`
- Configures HTTP trigger function container
- Sets up health probes (Startup, Readiness, Liveness)
- Configures environment variables for storage connection using managed identity
- Sets up scaling rules (1-3 replicas)

**Security Configuration:**
- Uses User-Assigned Managed Identity for secure access
- Configures secrets for revision-specific values
- Sets up container registry access with managed identity
- Uses managed identity for storage account access (no connection strings)

**Multiple Revision Setup:**
- Enables `activeRevisionsMode: 'Multiple'`
- Prepares secrets for multiple revisions
- Sets up infrastructure for traffic splitting (configured post-deployment)

---

## 5. Deployment Instructions

### Prerequisites

1. Install required tools:
   ```powershell
   # Install Azure CLI
   winget install Microsoft.AzureCLI
   
   # Install Bicep CLI
   az bicep install
   ```

2. Register required resource providers:
   ```powershell
   az provider register --namespace Microsoft.App
   az provider register --namespace Microsoft.OperationalInsights
   az provider register --namespace Microsoft.Insights
   az provider register --namespace Microsoft.Storage
   az provider register --namespace Microsoft.KeyVault
   ```

### Step-by-Step Deployment

1. **Set up your environment:**
   ```powershell
   $SUBSCRIPTION_ID = "<your-subscription-id>"
   $RESOURCE_GROUP = "<your-resource-group-name>"
   $LOCATION = "<your-region>"
   
   az login
   az account set --subscription $SUBSCRIPTION_ID
   az group create --name $RESOURCE_GROUP --location $LOCATION
   ```

2. **Deploy the infrastructure:**
   ```powershell
   $DEPLOYMENT_NAME = "aca-functions-multiple-revisions"
   
   az deployment group create `
       --name $DEPLOYMENT_NAME `
       --resource-group $RESOURCE_GROUP `
       --template-file main.bicep `
       --parameters containerAppName="my-function-app" `
                   environmentName="my-aca-env" `
                   containerRegistryName="myregistry" `
                   containerImageVersion="latest" `
                   httpStorageAccountName="httpstorage001" `
                   queueStorageAccountName="queuestorage001" `
                   revisionOneSecretValue="http-secret-value" `
                   revisionTwoSecretValue="queue-secret-value"
   ```

3. **Monitor deployment progress:**
   ```powershell
   # Watch deployment status
   az deployment group show --name $DEPLOYMENT_NAME --resource-group $RESOURCE_GROUP --query "properties.provisioningState"
   
   # Get deployment outputs
   az deployment group show --name $DEPLOYMENT_NAME --resource-group $RESOURCE_GROUP --query "properties.outputs"
   ```

### Post-Deployment Configuration

1. **Configure traffic splitting:**
   ```powershell
   # Update traffic weights after testing
   az containerapp revision set-mode --name "my-function-app" --resource-group $RESOURCE_GROUP --mode Multiple
   ```

2. **Verify health endpoints:**
   ```powershell
   # Test each revision individually
   $APP_FQDN = "<your-app-fqdn>"
   Invoke-RestMethod -Uri "https://$APP_FQDN/api/health" -Method GET
   ```

---

## 6. Best Practices Summary

### ✅ DO
- Use separate storage accounts for each revision
- Implement revision-specific secrets management
- Configure comprehensive health probes
- Use managed identity for authentication
- Plan resource allocation per revision
- Implement proper monitoring and alerting
- Test each revision independently before traffic splitting
- Use Key Vault for production secrets

### ❌ DON'T
- Share storage accounts between revisions unless necessary
- Use the same secrets across all revisions by default
- Deploy without proper health checks
- Use connection strings in production
- Ignore resource limits and scaling rules
- Skip monitoring and observability setup
- Deploy to production without testing

---

## 7. Troubleshooting

### Common Issues and Solutions

1. **Revision fails to start:**
   - Check storage account connectivity
   - Verify managed identity permissions
   - Review container logs in Azure portal

2. **Traffic not splitting correctly:**
   - Ensure both revisions are in "Running" state
   - Verify traffic configuration syntax
   - Check ingress configuration

3. **Performance issues:**
   - Monitor resource utilization per revision
   - Check for storage account throttling
   - Review scaling rules and limits

### Monitoring Commands

```powershell
# Check revision status
az containerapp revision list --name "my-function-app" --resource-group $RESOURCE_GROUP

# View logs
az containerapp logs show --name "my-function-app" --resource-group $RESOURCE_GROUP

# Check traffic distribution
az containerapp ingress traffic show --name "my-function-app" --resource-group $RESOURCE_GROUP
```

---

## 8. Additional Resources

- [Azure Container Apps Documentation](https://learn.microsoft.com/en-us/azure/container-apps/)
- [Azure Functions on Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/functions-overview)
- [Container Apps Revisions Management](https://learn.microsoft.com/en-us/azure/container-apps/revisions-manage)
- [Traffic Splitting Strategies](https://learn.microsoft.com/en-us/azure/container-apps/traffic-splitting)
- [Azure Functions Best Practices](https://learn.microsoft.com/en-us/azure/azure-functions/functions-best-practices)