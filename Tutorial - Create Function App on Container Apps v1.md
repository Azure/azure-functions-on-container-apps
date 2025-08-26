# Tutorial: Create your first containerized Azure Function on Azure Container Apps (v1)

> [!IMPORTANT]
> If you're creating a new function app for the first time, we recommend using the [Azure Functions on Azure Container Apps v2 (kind=functionapp)](./azure-functions-on-container-apps-v2.md) hosting option instead of this v1 approach.

## Overview

This tutorial shows you how to deploy a containerized Azure Function to Azure Container Apps. By the end of this tutorial, you'll have a function app running in a container on Azure Container Apps with the ability to scale dynamically based on demand.

## Prerequisites

Before you begin, ensure you have:

- An Azure subscription. If you don't have one, create a [free account](https://azure.microsoft.com/free/)
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) version 2.32.0 or later
- A Container Apps Environment and Storage Account configured. See [Prerequisites: Create Function App on Container Apps](./Prerequisite%20-%20Create%20Function%20App%20on%20Container%20Apps%20.md)
- A Docker image containing your function app (or use our quick start sample)

## Quick start with sample image

If you want to test with a pre-built sample HTTP trigger function, you can use this publicly accessible image:
```
mcr.microsoft.com/azure-functions/dotnet8-quickstart-demo:1.0
```

For your own images, ensure they are built and pushed to either Docker Hub or Azure Container Registry (ACR) in the format:
- Docker Hub: `<docker-id>/<image-name>:<tag>`
- ACR: `<registry-name>.azurecr.io/<image-name>:<tag>`

To create your own Azure Functions container image, refer to our [step-by-step tutorial](./Tutorial%20-%20Create%20an%20Azure%20Function%20Container%20Image.md) that walks you through building and containerizing your function app.

## Step 1: Create the function app

Use the [az functionapp create](https://learn.microsoft.com/en-us/cli/azure/functionapp#az-functionapp-create) command to create your function app in the Container Apps environment.

### Option A: Using Docker Hub

```bash
az functionapp create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $CONTAINER_APP_NAME \
  --environment $ENVIRONMENT_NAME \
  --storage-account <storage-name> \
  --functions-version 4 \
  --runtime dotnet-isolated \
  --image <docker-id>/<image-name>:<version> \
  --workload-profile-name <workload-profile-name> \
  --cpu <vcpus> \
  --memory <memory>
```

### Option B: Using Azure Container Registry

```bash
az functionapp create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $CONTAINER_APP_NAME \
  --environment $ENVIRONMENT_NAME \
  --storage-account <storage-name> \
  --functions-version 4 \
  --runtime dotnet-isolated \
  --image <acr-login-server>/<image-name>:<version> \
  --registry-username <username> \
  --registry-password <password> \
  --workload-profile-name <workload-profile-name> \
  --cpu <vcpus> \
  --memory <memory>
```

### Parameter reference

| Parameter | Description | Example |
|-----------|-------------|---------|
| `$CONTAINER_APP_NAME` | Globally unique name for your function app | `myfuncapp123` |
| `<storage-name>` | Name of your storage account (from prerequisites) | `mystorageaccount` |
| `<workload-profile-name>` | Use `"Consumption"` for consumption plan or your dedicated profile name | `"Consumption"` |
| `<vcpus>` | Number of vCPUs (see resource limits below) | `1` |
| `<memory>` | Memory allocation (see resource limits below) | `2Gi` |

### Resource limits

**Consumption workload profile:**
- CPU: 0.5 - 4 vCPUs
- Memory: 1Gi - 8Gi
- Default: 1 vCPU, 2Gi memory

**Dedicated/GPU workload profile:**
- CPU: 0.5 vCPUs to profile maximum
- Memory: 1Gi to profile maximum
- Default: 1 vCPU, 2Gi memory

## Step 2: Configure app settings

Configure the storage account connection string for your function app:

1. Get the storage account connection string:
   ```bash
   az storage account show-connection-string \
     --resource-group $RESOURCE_GROUP_NAME \
     --name <storage-name> \
     --query connectionString \
     --output tsv
   ```

2. Set the connection string as an app setting:
   ```bash
   az functionapp config appsettings set \
     --name $CONTAINER_APP_NAME \
     --resource-group $RESOURCE_GROUP_NAME \
     --settings AzureWebJobsStorage="<connection-string>"
   ```

## Step 3: Test your function

For HTTP-triggered functions:

1. Get the function URL:
   ```bash
   az functionapp function show \
     --resource-group $RESOURCE_GROUP_NAME \
     --name $CONTAINER_APP_NAME \
     --function-name <function-name> \
     --query "invokeUrlTemplate" \
     --output tsv
   ```

2. Test the function by navigating to the URL in your browser or using curl:
   ```
   https://<your-function-url>/api/HttpExample?name=HelloWorld
   ```

## Step 4: Update your function (optional)

### Update container image

To deploy a new version of your container image:

```bash
az functionapp config container set \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --image <registry>/<image-name>:<new-version> \
  --registry-username <username> \
  --registry-password <password>
```

### Change workload profile

To switch to a different workload profile:

```bash
az functionapp config container set \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --workload-profile-name <new-profile-name> \
  --cpu <vcpus> \
  --memory <memory>
```

### Configure scaling

To avoid cold starts and configure scaling:

```bash
az functionapp config container set \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --min-replicas <min-replicas> \
  --max-replicas <max-replicas>
```

## Clean up resources

To remove all resources created in this tutorial:

> [!CAUTION]
> This command deletes the entire resource group and all resources within it.

```bash
az group delete --name $RESOURCE_GROUP_NAME
```

## Troubleshooting

If you encounter issues, please [open an issue on GitHub](https://github.com/Azure/azure-functions-on-container-apps/issues).

## Next steps

- [Add a Queue Storage output binding](https://learn.microsoft.com/en-us/azure/azure-functions/functions-add-output-binding-storage-queue-cli?pivots=programming-language-csharp&tabs=in-process%2Cv1%2Cbash%2Cbrowser)
- [Deploy with Dapr extension](https://github.com/Azure/azure-functions-on-container-apps/tree/main/samples/azdsampleDAPRandFunctionsonACA)
- Set up continuous deployment with:
  - [GitHub Actions](https://github.com/Azure/azure-functions-on-container-apps/tree/main/samples/GitHubActions)
  - [Azure Pipelines](https://github.com/Azure/azure-functions-on-container-apps/tree/main/samples/AzurePipelineTasks)
- Learn about [Dapr Extension for Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-dapr)