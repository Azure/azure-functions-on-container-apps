# Blob Store Trigger: Azure Functions on Container Apps

## Objective

This tutorial demonstrates how to deploy an **Azure Functions application** to Azure Container Apps (ACA) that responds to blob storage events. We'll build a containerized Azure Functions app with:

1. **Blob Trigger Function**: Automatically processes files uploaded to Azure Blob Storage
2. **HTTP API Endpoint**: Provides a REST endpoint to retrieve upload information
3. **Container Deployment**: Packaged as a Docker container for Azure Container Apps
4. **Production-Ready**: Uses proper Azure Container Registry integration and environment configuration

## Prerequisites

- Docker Desktop running
- Azure CLI logged in: `az login`
- Azure Functions Core Tools (optional for local testing)
- An Azure Container Registry (ACR) 
- An Azure Container Apps managed environment
- A Storage Account with a blob container named **'uploads'** (this is where files should be uploaded to trigger the function)

## Project Structure

```
├── Dockerfile                 # Container build configuration
├── host.json                 # Azure Functions host configuration
├── local.settings.json       # Local development settings (not for production)
├── package.json              # Node.js dependencies
└── src/
    └── functions/
        ├── blobTrigger.js     # Blob storage trigger function
        └── blobwithhttp.js    # HTTP endpoint for retrieving uploads
```

## Key Files Explained

- **`src/functions/blobTrigger.js`** — Responds to blob storage events when files are uploaded to the **'uploads'** container
- **`src/functions/blobwithhttp.js`** — HTTP endpoint at `/api/GetUploads` to retrieve information about processed blob uploads
- **`Dockerfile`** — Container build configuration for Azure Functions runtime
- **`host.json`** — Azure Functions runtime configuration

**Important**: The blob trigger function is configured to monitor the **'uploads'** blob container in your storage account. Make sure this container exists before testing.

## Variable Setup

Set these PowerShell variables before running commands (customize for your environment):

```powershell
$RG = "your-resource-group"                    # Your Azure resource group
$ENV = "your-aca-environment"                  # Your ACA managed environment name
$ACR = "your-container-registry"               # Your ACR name (without .azurecr.io)
$APP = "your-app-name"                         # Your container app name
$IMAGE_TAG = "blobfunctionimage:v2.0.3"
$ACR_IMAGE = "$ACR.azurecr.io/$IMAGE_TAG"
$STORAGE_CONN_STRING = "your-storage-connection-string"  # Your storage account connection string
$ACR_USERNAME = "your-acr-username"            # Your ACR username
$ACR_PASSWORD = "your-acr-password"            # Your ACR password
```

## Step-by-Step Deployment

### 1. Build the Docker Image

```powershell
# Navigate to the project directory
Set-Location "path\to\your\project"

# Build the image
docker build -t $IMAGE_TAG .
```

The Dockerfile configures the Azure Functions runtime environment and exposes the application on port 8080.

### 2. Push to Azure Container Registry

```powershell
# Tag for your registry
docker tag $IMAGE_TAG $ACR_IMAGE

# Login to ACR
az acr login --name $ACR

# Push the image
docker push $ACR_IMAGE
```

### 3. Deploy to Azure Container Apps

#### Option A: Using ACR Credentials

```powershell
# Get ACR credentials
$acrCred = az acr credential show --name $ACR --query "{username:username,password:passwords[0].value}" -o json | ConvertFrom-Json
$ACR_USERNAME = $acrCred.username
$ACR_PASSWORD = $acrCred.password

# Create the container app
az containerapp create `
  --name $APP `
  --resource-group $RG `
  --environment $ENV `
  --image $ACR_IMAGE `
  --target-port 8080 `
  --ingress external `
  --registry-server "$ACR.azurecr.io" `
  --registry-username $ACR_USERNAME `
  --registry-password $ACR_PASSWORD `
  --env-vars AzureWebJobsStorage="$STORAGE_CONN_STRING" FUNCTIONS_WORKER_RUNTIME=node AzureWebJobsFeatureFlags=EnableWorkerIndexing ASPNETCORE_URLS="http://+:8080"
```

#### Option B: Complete Command Example

Here's a complete example of the `az containerapp create` command with all parameters:

```powershell
az containerapp create `
  --name blobfunc-app `
  --resource-group myResourceGroup `
  --environment myContainerEnvironment `
  --image myregistry.azurecr.io/blobfunctionimage:v2.0.3 `
  --target-port 8080 `
  --ingress external `
  --registry-server myregistry.azurecr.io `
  --registry-username MyRegistryUsername `
  --registry-password "MyRegistryPassword123!" `
  --env-vars AzureWebJobsStorage="DefaultEndpointsProtocol=https;AccountName=mystorageaccount;AccountKey=myStorageKey123==;EndpointSuffix=core.windows.net" FUNCTIONS_WORKER_RUNTIME=node AzureWebJobsFeatureFlags=EnableWorkerIndexing ASPNETCORE_URLS="http://+:8080"
```

**Command Breakdown:**
- `--name`: The name of your container app
- `--resource-group`: Your Azure resource group
- `--environment`: Your Container Apps environment
- `--image`: Full path to your container image in ACR
- `--target-port 8080`: The port your application listens on
- `--ingress external`: Makes the app accessible from the internet
- `--registry-server`: Your ACR server URL
- `--registry-username`: ACR username for authentication
- `--registry-password`: ACR password for authentication
- `--env-vars`: Environment variables needed by Azure Functions:
  - `AzureWebJobsStorage`: Connection string to your storage account
  - `FUNCTIONS_WORKER_RUNTIME=node`: Specifies Node.js runtime
  - `AzureWebJobsFeatureFlags=EnableWorkerIndexing`: Enables function indexing
  - `ASPNETCORE_URLS="http://+:8080"`: Configures the listening port

### 4. Verify Your Deployment

```powershell
# Check container app status
az containerapp show --name $APP --resource-group $RG --query "{status:properties.runningStatus,fqdn:properties.configuration.ingress.fqdn}" -o table

# View logs to confirm functions are loaded
az containerapp logs show --resource-group $RG --name $APP --tail 20

# Test the HTTP endpoint
$FQDN = az containerapp show --name $APP --resource-group $RG --query "properties.configuration.ingress.fqdn" -o tsv
Invoke-RestMethod "https://$FQDN/api/GetUploads"
```

### 5. Test Blob Trigger Functionality

**Step 1: Upload a file to trigger the function**
1. Navigate to your Azure Storage Account in the Azure Portal
2. Go to **Containers** and select the **'uploads'** container (create it if it doesn't exist)
3. Upload any file (image, text file, etc.) to the **'uploads'** container

**Step 2: Monitor function execution**
2. **Check the logs** to see the blob trigger function execute:
   ```powershell
   az containerapp logs show --resource-group $RG --name $APP --follow
   ```
   You should see log entries showing the function processing your uploaded file.

**Step 3: Verify results via HTTP endpoint**
3. **Call the GetUploads endpoint** to see the processed uploads and monitor changes:
   ```powershell
   # Get your app's FQDN and call the monitoring endpoint
   $FQDN = az containerapp show --name $APP --resource-group $RG --query "properties.configuration.ingress.fqdn" -o tsv
   Invoke-RestMethod "https://$FQDN/api/GetUploads"
   ```

**Expected Workflow:**
1. File uploaded to 'uploads' container → Blob trigger fires → Function processes file → Results available via `/api/GetUploads`

**Monitoring URL**: Use `https://<FQDN>/api/GetUploads` to monitor changes and outcomes of your function triggers. This endpoint will show you information about all files that have been processed by the blob trigger function.

## Production Recommendations

### Monitor Function Triggers and Results
```powershell
# View function execution logs
az containerapp logs show --resource-group $RG --name $APP --tail 100 | Select-String "Executed"

# Monitor blob processing results via HTTP endpoint
$FQDN = az containerapp show --name $APP --resource-group $RG --query "properties.configuration.ingress.fqdn" -o tsv
Invoke-RestMethod "https://$FQDN/api/GetUploads"
```

**Key Monitoring Points:**
- **Logs**: Show real-time function execution when files are uploaded to 'uploads' container
- **GetUploads Endpoint**: `https://<FQDN>/api/GetUploads` provides results of all processed blob trigger events
- **Status**: Container app health and running status


## Troubleshooting Checklist

✅ **Container Registry**: Verify ACR credentials and image exists  
✅ **Environment Variables**: Confirm all required variables are set  
✅ **Storage Account**: Test connection string and 'uploads' blob container exists  
✅ **Port Configuration**: Ensure target port matches application port  
✅ **Resource Permissions**: Verify resource group and environment access  
✅ **Blob Container**: Confirm the 'uploads' container exists and files are uploaded there  
✅ **Function Monitoring**: Use `https://<FQDN>/api/GetUploads` to verify blob trigger processing  

---

This tutorial provides a complete guide for deploying Azure Functions with blob storage triggers to Azure Container Apps, covering both development and production scenarios.
