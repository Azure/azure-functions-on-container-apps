# Create your first Azure Function on Azure Container Apps v2

Learn how to deploy and manage Azure Functions on Azure Container Apps. This tutorial walks you through creating a function app, deploying it to Container Apps, and managing your deployment.

> **Note:** For the latest information, see the [official documentation](https://learn.microsoft.com/en-us/azure/container-apps/functions-usage).

## Prerequisites

Before you begin, ensure you have:
- Azure Container Apps Environment configured
- Azure Storage Account provisioned

For detailed setup instructions, see [Prerequisite - Create Function App on Container Apps](./Prerequisite%20-%20Create%20Function%20App%20on%20Container%20Apps%20.md).

## Deploy your Function App

You can deploy using either a pre-built demo image or your own container image.

### Option 1: Quick Start with Demo Image

Deploy a sample HTTP trigger function using Microsoft's demo image:

```sh
az containerapp create --resource-group MyResourceGroup \
    --name $FUNCTIONS_CONTAINER_APP_NAME \
    --environment $ENVIRONMENT_NAME \
    --image mcr.microsoft.com/azure-functions/dotnet8-quickstart-demo:1.0 \
    --ingress external \
    --target-port 80 \
    --kind functionapp \
    --query properties.outputs.fqdn
```

### Option 2: Deploy from Docker Hub

Use your own Docker Hub image:

```sh
az containerapp create --resource-group MyResourceGroup \
    --name <function_containerapp_name> \
    --environment MyContainerappEnvironment \
    --image <DOCKER_ID>/<image_name>:<version> \
    --workload-profile-name <WORKLOAD_PROFILE_NAME> \
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

```sh
az containerapp create --resource-group MyResourceGroup \
    --name <function_containerapp_name> \
    --environment MyContainerappEnvironment \
    --image <acr-login-server>/<image_name>:<version> \
    --registry-username <user_name> \
    --registry-password <user_password> \
    --workload-profile-name <WORKLOAD_PROFILE_NAME> \
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

```sh
az storage account show-connection-string \
    --resource-group <Resource_group> \
    --name <STORAGE_NAME> \
    --query connectionString \
    --output tsv
```

### Step 2: Update Application Settings

```sh
az containerapp update \
    --name <your-containerapp-name> \
    --resource-group <your-resource-group> \
    --set-env-vars \
    AzureWebJobsStorage=<your-storage-connection-string> \
    APPLICATIONINSIGHTS_CONNECTION_STRING=<your-application-insights-connection-string>
```

> **Tip:** For secrets in ACR, prefix values with `secretref:` followed by the secret name.

## Test Your Function

### Get the Function URL

```sh
az containerapp show \
    --name <your-containerapp-name> \
    --resource-group <your-resource-group> \
    --query properties.configuration.ingress.fqdn \
    --output tsv
```

### Invoke the Function

1. Copy the URL from the command output
2. Open in a web browser
3. Append `/api/HttpExample` to the URL
4. You should see: "HTTP trigger function processed a request"

**Example URL:** `http://myfuncapponaca.gray-a2b3ceef.northeurope.azurecontainerapps.io/api/HttpExample`

## Update Your Function

### Update Container Image

Deploy a new version of your function:

```sh
az containerapp update \
    --name <my-funccontainerapp> \
    --resource-group <MyResourceGroup> \
    --image <myregistry.azurecr.io/my-funcapp:v2.0> \
    --registry-password <Password> \
    --registry-username <DockerUserId>
```

### Update Workload Profile

Change the workload profile configuration:

```sh
az containerapp update \
    --name <my-funccontainerapp> \
    --resource-group <MyResourceGroup> \
    --workload-profile-name <workload-profile-name> \
    --cpu <vcpus> \
    --memory <memory>
```

### Configure Scaling

Adjust replica settings to optimize performance:

```sh
az containerapp update \
    --name <my-funccontainerapp> \
    --resource-group <MyResourceGroup> \
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

```sh
az group delete --name $RESOURCE_GROUP
```

> **Warning:** This command deletes the entire resource group and all resources within it. Ensure you don't have other important resources in this group before deletion.

## Need Help?

If you encounter issues, [open an issue on GitHub](https://github.com/Azure/azure-functions-on-container-apps/issues).
