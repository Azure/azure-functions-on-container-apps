# Create your first Azure Function on Azure Container Apps v2

Learn how to deploy and manage Azure Functions on Azure Container Apps. This tutorial walks you through creating a function app, deploying it to Container Apps, and managing your deployment.

> **Note:** For the latest information, see the [official documentation](https://learn.microsoft.com/en-us/azure/container-apps/functions-usage).

## Prerequisites

Before you begin, ensure you have:
- Environment variables are setup with replacing placeholders
- Azure Container Apps Environment provisioned
- Azure Storage Account provisioned

For detailed setup instructions, see [Prerequisite - Create Function App on Container Apps](./Prerequisite%20-%20Create%20Function%20App%20on%20Container%20Apps%20.md).


## Deploy your Function App

You can deploy using either a pre-built demo image or your own container image. 

To create your own Azure Functions container image, refer to our [step-by-step tutorial](./Tutorial%20-%20Create%20an%20Azure%20Function%20Container%20Image.md) that walks you through building and containerizing your function app.

### Option 1: Quick Start with Demo Image

Deploy a sample HTTP trigger function using Microsoft's demo image:

```bash
az containerapp create --resource-group $RESOURCE_GROUP_NAME \
    --name $CONTAINER_APP_NAME \
    --environment $ENVIRONMENT_NAME \
    --image mcr.microsoft.com/azure-functions/dotnet8-quickstart-demo:1.0 \
    --ingress external \
    --target-port 80 \
    --kind functionapp \
    --query properties.outputs.fqdn
```

### Option 2: Deploy from Docker Hub

Use your own Docker Hub image:

```bash
az containerapp create --resource-group $RESOURCE_GROUP_NAME \
    --name $CONTAINER_APP_NAME \
    --environment $ENVIRONMENT_NAME \
    --image <DOCKER_ID>/<image_name>:<version> \
    --workload-profile-name Consumption \
    --cpu <vcpus> \
    --memory <memory> \
    --ingress external \
    --target-port 80 \
    --kind functionapp \
    --env-vars AzureWebJobsStorage=<your-storage-connection-string> \
               APPLICATIONINSIGHTS_CONNECTION_STRING=<your-application-insights-connection-string> \
    --query properties.outputs.fqdn
```

### Option 3: Deploy from Azure Container Registry (ACR)

Deploy using an image from ACR:

```bash
az containerapp create --resource-group $RESOURCE_GROUP_NAME \
    --name $CONTAINER_APP_NAME \
    --environment $ENVIRONMENT_NAME \
    --image <acr-login-server>/<image_name>:<version> \
    --registry-username <user_name> \
    --registry-password <user_password> \
    --workload-profile-name <my-dedicated-workload-profile-name> \
    --cpu <vcpus> \
    --memory <memory> \
    --ingress external \
    --target-port 80 \
    --kind functionapp \
    --env-vars AzureWebJobsStorage=<your-storage-connection-string> \
                        APPLICATIONINSIGHTS_CONNECTION_STRING=<your-application-insights-connection-string> \
    --query properties.outputs.fqdn
```

## Configure Workload Profiles

Choose between Consumption or Dedicated workload profiles based on your requirements.
> **Note:** For the latest information on workload profiles, see the [official documentation](https://learn.microsoft.com/en-us/azure/container-apps/workload-profiles-overview).

### Consumption Profile
- **CPU:** 0.25 - 4 vCPUs
- **Memory:** 0.5Gi - 8Gi
- **Default:** 0.5 vCPU, 1Gi memory
- **Configuration:** Set `--workload-profile-name "Consumption"`

### Dedicated/GPU Profile
- **CPU:** 0.25 vCPUs - profile type maximum
- **Memory:** 0.5Gi - profile type maximum
- **Default:** 0.5 vCPU, 1Gi memory

## Configure Application Settings

### Step 1: Retrieve Storage Connection String

```bash
az storage account show-connection-string \
    --resource-group $RESOURCE_GROUP_NAME \
    --name <STORAGE_NAME> \
    --query connectionString \
    --output tsv
```

### Step 2: Update Application Settings

```bash
az containerapp update \
    --name $CONTAINER_APP_NAME  \
    --resource-group $RESOURCE_GROUP_NAME \
    --set-env-vars \
    AzureWebJobsStorage=<your-storage-connection-string>
```

Optionally set env variable `APPLICATIONINSIGHTS_CONNECTION_STRING` too if you want to integrate with Azure App Insights.

> **Tip:** For secrets in ACR, prefix values with `secretref:` followed by the secret name.

## Test Your Function

### Get the Function URL

```bash
az containerapp show \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --query properties.configuration.ingress.fqdn \
    --output tsv
```

### Invoke the Function

1. Copy the URL from the command output
2. Open in a web browser
3. Append `/api/HttpExample` to the URL
4. You should see: "HTTP trigger function processed a request" with HTTP 200 OK response code.

**Example URL:** `http://my-aca-functions-app.gray-a2b3ceef.northeurope.azurecontainerapps.io/api/HttpExample`

Bash command to validate endpoint is working or not

```bash
curl http://my-aca-functions-app.gray-a2b3ceef.northeurope.azurecontainerapps.io/api/HttpExample -v
```

## Update Your Function

### Update Container Image

Deploy a new version of your function:

```bash
az containerapp update \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --image <myregistry.azurecr.io/my-funcapp:v2.0> \
    --registry-password <Password> \
    --registry-username <DockerUserId>
```

### Update Workload Profile

Change the workload profile configuration:

```bash
az containerapp update \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --workload-profile-name <workload-profile-name> \
    --cpu <vcpus> \
    --memory <memory>
```

### Configure Scaling

Adjust replica settings to optimize performance:

```bash
az containerapp update \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --cpu 0.5 \
    --memory 1.0Gi \
    --min-replicas 4 \
    --max-replicas 8
```

## Managed Identity Support

Azure Functions on Container Apps supports both system-assigned and user-assigned managed identities. Use managed identities to:

- Access Azure Key Vault secrets
- Connect to Azure Storage
- Pull images from Azure Container Registry
- Configure triggers and bindings

Learn more:
- [Managed identities for Azure resources](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)
- [Managed Identity samples](https://github.com/Azure/azure-functions-on-container-apps/tree/main/samples/Biceptemplates/MI_VNET_sample)

## Clean Up Resources

Remove all resources created in this tutorial:

```bash
az group delete --name $RESOURCE_GROUP
```

> **Warning:** This command deletes the entire resource group and all resources within it. Ensure you don't have other important resources in this group before deletion.

## Need Help?

> **Note**: If you encounter any issues with the steps in this tutorial, refer to the [official Azure Functions on container App documentation](https://learn.microsoft.com/en-us/azure/container-apps/functions-usage) for the most up-to-date information, as the public documentation is updated more frequently.


If you encounter issues, [open an issue on GitHub](https://github.com/Azure/azure-functions-on-container-apps/issues).
