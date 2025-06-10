# Native Azure Functions on Azure Container Apps (ACA) Bicep Sample

This repository provides a minimal Bicep template (`main.bicep`) to deploy Azure Functions natively on Azure Container Apps, along with a quick-start README.

---

## 1. Introduction

Azure Container Apps now includes **native Azure Functions** support by setting the `kind=functionapp` property on a Container App resource. This enables you to combine the rich programming model and auto-scaling capabilities of Azure Functions with the flexible, serverless container hosting environment of Container Apps.
- Read the official announcement blog post:  
  https://techcommunity.microsoft.com/blog/AppsonAzureBlog/announcing-native-azure-functions-support-in-azure-container-apps/4414039
- Learn more in the product documentation:  
  https://learn.microsoft.com/en-us/azure/container-apps/functions-overview 

---

## 2. Template Structure

The provided `main.bicep` template does the following:  
1. Creates a Log Analytics workspace for diagnostics and monitoring.  
2. Provisions a Container Apps environment with Consumption‐based workload profile.  
3. Deploys a Storage account and Application Insights for function host storage and telemetry.  
4. Deploys the Functions Container app (with `kind=functionapp`) using the specified Docker image, runtime, and secrets.
   - The template uses a quickstart functions docker image. You can replace it with your own image that is compatible with Azure Functions host expectations - [Create a function app in a local Linux container](https://learn.microsoft.com/en-us/azure/azure-functions/functions-create-container-registry).
5. Outputs the resource Id and fully qualified domain name (FQDN) endpoint of your Functions Container App.

---

## 3. Deployment

1. Clone or download the `main.bicep` file from the current folder.   

1. Ensure you have the latest [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) and [Bicep CLI](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install) installed.    

1. Ensure the following Resource Providers are registered in your subscription:
   - Microsoft.App
   - Microsoft.OperationalInsights
   - Microsoft.Insights
   - Microsoft.Storage
 
1. Log in and select your target subscription and resource group:  
    ```bash
    SUBSCRIPTION_ID="<your-subscription-id>"
    RESOURCE_GROUP="<your-resource-group-name>"
    LOCATION="<your-region>"
    az login
    az account set --subscription "$SUBSCRIPTION_ID"
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
    ```

1. Deploy the Bicep template using the Azure CLI:
    > **WARNING**
    > This sample uses connection strings to keep the template lightweight. For production scenarios, it's strongly recommended to use [Managed Identity](https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference?tabs=servicebus&pivots=programming-language-python#configure-an-identity-based-connection) for improved security and operational best practices.

    > **Note:**  
    > All required parameters have default values, but you can override them by passing `--parameters` in the `az deployment group create` command.

    ```bash
    DEPLOYMENT_NAME="aca-functions-deployment"
    az deployment group create \
        --name "$DEPLOYMENT_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --template-file main.bicep
    ```
    View the deployment progress in the Azure portal or via the CLI. The deployment may take a few minutes to complete.

1. Access your Functions Container App:
    After deployment, the output will display the fully qualified domain name (FQDN) of your Functions Container App. You can also find it in the Azure portal under the **Container Apps** resource, listed with the type `Container App (Function)`.

    To test your function, you can use `curl` or any HTTP client:
    ```bash
    curl -X GET "https://<your-app-name>.<environment-identifier>.<region>.azurecontainerapps.io/api/<your-function-name>"
    ```

1. Clean up resources when done:
    ```bash
    az group delete --name "$RESOURCE_GROUP" --yes --no-wait
    ``` 

For additional customization, modify the `main.bicep` file accordingly.