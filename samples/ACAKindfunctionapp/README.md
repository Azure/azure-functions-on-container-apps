# Native Azure Functions on Azure Container Apps (ACA) Bicep Sample

This repository provides a minimal Bicep template (`main.bicep`) to deploy Azure Functions natively on Azure Container Apps, along with a quick-start README.

---

## 1. Introduction

Azure Container Apps now supports running Azure Functions as a “functionapp” kind of container workload. This enables you to combine the rich programming model and auto-scaling capabilities of Azure Functions with the flexible, serverless container hosting environment of Container Apps.
- Read the official announcement blog post:  
  https://techcommunity.microsoft.com/blog/AppsonAzureBlog/announcing-native-azure-functions-support-in-azure-container-apps/4414039
- Learn more in the product documentation:  
  https://learn.microsoft.com/en-us/azure/container-apps/functions-overview 

---

## 2. Template Structure

The provided `main.bicep` template does the following:  
1. **Creates a Log Analytics workspace** for diagnostics and monitoring.  
2. **Provisions a Container Apps environment** with Consumption‐based workload profile.  
3. **Deploys a Storage account** and **Application Insights** for function host storage and telemetry.  
4. **Deploys the Functions Container app** (kind=`functionapp`) using specified Docker image, runtime, and secrets.
5. **Outputs** the resource ID and fully qualified domain name (FQDN) of your Functions Container App endpoint.

---

## 3. Deployment

1. **Clone or download** this repository. 
2. 2. Ensure you have the latest [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) and [Bicep CLI](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install) installed.    
 
3. Log in and select your target subscription and resource group:  
    ```bash
    SUBSCRIPTION_ID="<your-subscription-id>"
    RESOURCE_GROUP="<your-resource-group-name>"
    LOCATION="<your-region>"
    az login
    az account set --subscription "$SUBSCRIPTION_ID"
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
    ```
4. **Deploy the Bicep template** using the Azure CLI:  
    ```bash
    DEPLOYMENT_NAME="aca-functions-deployment"
    az deployment group create \
        --name "$DEPLOYMENT_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --template-file main.bicep
    ```
5. **Monitor the deployment**:
    ```bash
    az deployment group show --name "$DEPLOYMENT_NAME" --resource-group "$RESOURCE_GROUP"
    ``` 

6. **Clean up resources** when done:
    ```bash
    az group delete --name "$RESOURCE_GROUP" --yes --no-wait
    ``` 

For more detail on parameters and customization, edit the main.bicep file as needed.