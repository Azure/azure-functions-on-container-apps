# Prerequisites: Create Azure Functions on Azure Container Apps

This article guides you through setting up the essential Azure resources needed to host Azure Functions on Azure Container Apps. You'll create an Azure Container Apps Environment (which provides the compute infrastructure) and an Azure Storage Account (required for function triggers and logging).

## Prerequisites

- Azure subscription - [Create one for free](https://azure.microsoft.com/free/)
- [Azure CLI](/cli/azure/install-azure-cli) version 2.53.0 or later
- Azure Container Apps extension for Azure CLI

## Set up your environment

1. **Sign in to Azure and install required extensions**

  ```bash
  az login
  az upgrade
  az extension add --name containerapp --upgrade
  ```

2. **Set environment variables**

  Replace the placeholder values with your own:

  ```bash
  SUBSCRIPTION_ID="subscription-id"
  RESOURCE_GROUP_NAME="my-aca-functions-group"
  CONTAINER_APP_NAME="my-aca-functions-app"
  ENVIRONMENT_NAME="my-aca-functions-environment"
  WORKLOAD_PROFILE_NAME="my-functions-workload-profile"
  LOCATION="northeurope"
  ```

3. **Configure your subscription and register resource providers**

  ```bash
  az account set --subscription $SUBSCRIPTION_ID
  
  az provider register --namespace Microsoft.Web
  az provider register --namespace Microsoft.App
  az provider register --namespace Microsoft.OperationalInsights
  ```

## Create a resource group

Create a resource group to contain all the resources for this tutorial:

```bash
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION
```

## Create an Azure Container Apps environment

Azure Container Apps environments act as a secure boundary around a group of container apps. Functions deployed to the same environment share the same virtual network and write logs to the same Log Analytics workspace.

### About workload profiles

Workload profiles determine the compute and memory resources available to your container apps. Azure Functions on Azure Container Apps supports two types of workload profiles:

- **Consumption profile**: Serverless apps with scale-to-zero support. Pay only for resources your apps use.
- **Dedicated profile**: Customized hardware with predictable costs. Fixed pricing for the entire environment.

### Option 1: Create environment with Consumption workload profile (Recommended)

The Consumption profile is the default profile and ideal for most scenarios:

```bash
az containerapp env create \
  --enable-workload-profiles \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $ENVIRONMENT_NAME \
  --location $LOCATION
```

> **Note**: This command can take up to 10 minutes to complete.

Verify the environment creation:

```bash
az containerapp env show \
  --name $ENVIRONMENT_NAME \
  --resource-group $RESOURCE_GROUP_NAME
```

Wait until `provisioningState` shows **Succeeded** before proceeding.

### Option 2: Add a Dedicated workload profile (GPU support)

If you need customized hardware or GPU support, add a Dedicated profile to your existing environment:

```bash
az containerapp env workload-profile add \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $ENVIRONMENT_NAME \
  --workload-profile-type "Dedicated" \
  --workload-profile-name $WORKLOAD_PROFILE_NAME \
  --min-nodes 1 \
  --max-nodes 3
```

The workload profile name is a friendly identifier you'll use when deploying container apps to this profile. You can add multiple profiles of the same type using different names.

For more information about managing workload profiles, see [Manage workload profiles using Azure CLI](https://learn.microsoft.com/azure/container-apps/workload-profiles-manage-cli).

## Create an Azure Storage account

Azure Functions requires a storage account for triggers and logging function executions. Create a general-purpose storage account:

```bash
az storage account create \
  --name <STORAGE_NAME> \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP_NAME \
  --sku Standard_LRS
```

> **Important**: 
> - Storage account names must be globally unique across Azure
> - Names must contain 3-24 characters (lowercase letters and numbers only)
> - Standard_LRS specifies a general-purpose account, which is [supported by Functions](https://learn.microsoft.com/azure/azure-functions/storage-considerations#storage-account-requirements)

## Next steps

After completing these prerequisites, you're ready to:

- [Create an Azure Function Container Image for Azure Container Apps hosting](./Tutorial%20-%20Create%20an%20Azure%20Function%20Container%20Image.md)
- [Deploy your first function app to Azure Container Apps](./Tutorial%20-%20Create%20Function%20App%20on%20Container%20Apps%20v2.md)

## Related resources

- [Azure Functions on Azure Container Apps overview](https://learn.microsoft.com/en-us/azure/container-apps/functions-overview)
- [Workload profiles overview](https://learn.microsoft.com/azure/container-apps/workload-profiles-overview)
- [Azure Functions hosting options](https://learn.microsoft.com/azure/azure-functions/functions-scale)