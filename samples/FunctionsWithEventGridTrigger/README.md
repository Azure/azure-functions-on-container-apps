# EventGrid Trigger: Azure Functions on Container Apps

## Objective

This tutorial demonstrates how to deploy an **Azure Functions application** to Azure Container Apps (ACA) that responds to EventGrid events. We'll build a containerized Azure Functions app with:

1. **EventGrid Trigger Function**: Automatically processes events from Azure EventGrid
2. **HTTP API Endpoint**: Provides a REST endpoint to retrieve event information
3. **Container Deployment**: Packaged as a Docker container for Azure Container Apps
4. **Production-Ready**: Uses proper Azure Container Registry integration and environment configuration

## 📹 Walkthrough

Watch the complete walkthrough demonstrating EventGrid triggers with Azure Functions on Container Apps:

<video width="800" controls>
  <source src="./Event%20Hub%20Trigger%20with%20functions%20in%20Container%20Apps.mp4" type="video/mp4">
  Your browser does not support the video tag. <a href="./Event%20Hub%20Trigger%20with%20functions%20in%20Container%20Apps.mp4">Download the video</a>
</video>

## Prerequisites

- Docker Desktop running
- Azure CLI logged in: `az login`
- Azure Functions Core Tools (optional for local testing)
- An Azure Container Registry (ACR)
- An Azure Container Apps managed environment
- An EventGrid topic or system topic configured to send events

## Project Structure

```
├── Dockerfile         # Container build configuration
├── host.json                   # Azure Functions host configuration
├── local.settings.json         # Local development settings (not for production)
├── package.json                # Node.js dependencies (points to eventgridwithhttp.js)
└── src/
    └── functions/
        └── eventgridwithhttp.js # EventGrid trigger function with HTTP endpoint (main entry point)
```

## Key Files Explained

- **`src/functions/eventgridwithhttp.js`** — Responds to EventGrid events and provides HTTP endpoint at `/api/GetEvents` to retrieve information about processed events
- **`Dockerfile`** — Container build configuration for Azure Functions runtime
- **`host.json`** — Azure Functions runtime configuration

**Important**: The EventGrid trigger function is configured to respond to events sent to the function endpoint. Make sure to configure your EventGrid topic to send events to this function.

## Variable Setup

Set these PowerShell variables before running commands (customize for your environment):

```powershell
$RG = "your-resource-group"                    # Your Azure resource group
$ENV = "your-aca-environment"                  # Your ACA managed environment name
$ACR = "your-container-registry"               # Your ACR name (without .azurecr.io)
$APP = "your-app-name"                         # Your container app name
$IMAGE_TAG = "eventgrid-functions:v1.0.0"
$ACR_IMAGE = "$ACR.azurecr.io/$IMAGE_TAG"
$STORAGE_CONN_STRING = "your-storage-connection-string"  # Your storage account connection string
$ACR_USERNAME = "your-acr-username"            # Your ACR username
$ACR_PASSWORD = "your-acr-password"            # Your ACR password
```

## Deployment Options

This project includes automated PowerShell deployment scripts for easy deployment:

### Option 1: Automated Deployment (Recommended)

**Using ACR Build (No Local Docker Required)**:
```powershell
.\deploy-eventgrid-aca-build.ps1
```

The script will:
- Build the container image (either in ACR or locally)
- Push to Azure Container Registry
- Deploy to Azure Container Apps
- Configure all necessary environment variables

**Before running the scripts**, edit these parameters at the top of the deployment files:

```powershell
# Update these values in deploy-eventgrid-acr-build.ps1 or deploy-eventgrid-containerapp.ps1
$SubscriptionId = "your-subscription-id"
$ResourceGroup = "your-resource-group"  
$ContainerRegistry = "your-acr-name"
$AppName = "your-app-name"
$Environment = "your-container-environment"
```

You'll also need to update the storage connection string variable in the script.

### Option 2: Manual Step-by-Step Deployment

### 1. Build the Docker Image

```powershell
# Navigate to the project directory
Set-Location "path\to\your\project"

# Build the image using the EventGrid-specific Dockerfile
docker build -f Dockerfile -t $IMAGE_TAG .
```

The Dockerfile configures the Azure Functions runtime environment and exposes the application on port 80.

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

Deploy the container app using `--kind functionapp` for enhanced Azure Functions integration:

```powershell
# Get ACR credentials
$acrCred = az acr credential show --name $ACR --query "{username:username,password:passwords[0].value}" -o json | ConvertFrom-Json
$ACR_USERNAME = $acrCred.username
$ACR_PASSWORD = $acrCred.password

# Create the container app with function app kind (recommended)
az containerapp create `
  --name $APP `
  --resource-group $RG `
  --environment $ENV `
  --image $ACR_IMAGE `
  --target-port 80 `
  --ingress external `
  --registry-server "$ACR.azurecr.io" `
  --registry-username $ACR_USERNAME `
  --registry-password $ACR_PASSWORD `
  --env-vars AzureWebJobsStorage="$STORAGE_CONN_STRING" FUNCTIONS_WORKER_RUNTIME=node AzureWebJobsFeatureFlags=EnableWorkerIndexing ASPNETCORE_URLS="http://+:80" `
  --kind functionapp
```

**Benefits of using `--kind functionapp`:**
- Enhanced Azure Functions runtime integration
- Better function-specific monitoring and metrics  
- Optimized scaling for Azure Functions workloads
- Preview feature with dedicated Functions support

### 4. Verify Your Deployment

```powershell
# Check container app status
az containerapp show --name $APP --resource-group $RG --query "{status:properties.runningStatus,fqdn:properties.configuration.ingress.fqdn}" -o table

# View logs to confirm functions are loaded
az containerapp logs show --resource-group $RG --name $APP --tail 20

# Test the HTTP endpoint
$FQDN = az containerapp show --name $APP --resource-group $RG --query "properties.configuration.ingress.fqdn" -o tsv
Invoke-RestMethod "https://$FQDN/api/eventGridHttp"
```

### 5. Test EventGrid Trigger Functionality

**Step 1: Configure EventGrid Subscription**
1. Navigate to your EventGrid topic in the Azure Portal
2. Create a new subscription that points to your function endpoint
3. Set the endpoint URL to: `https://<FQDN>/runtime/webhooks/eventgrid?functionName=EventGridTriggerFunction`

**Step 2: Monitor function execution**
1. **Check the logs** to see the EventGrid trigger function execute:
   ```powershell
   az containerapp logs show --resource-group $RG --name $APP --follow
   ```
   You should see log entries showing the function processing your EventGrid events.

**Step 3: Verify results via HTTP endpoint**
2. **Call the GetEvents endpoint** to see the processed events:
   ```powershell
   # Get your app's FQDN and call the monitoring endpoint
   $FQDN = az containerapp show --name $APP --resource-group $RG --query "properties.configuration.ingress.fqdn" -o tsv
   Invoke-RestMethod "https://$FQDN/api/GetEvents"
   ```

**Expected Workflow:**
1. EventGrid event published → EventGrid trigger fires → Function processes event → Results available via `/api/GetEvents`

**Monitoring URL**: Use `https://<FQDN>/api/GetEvents` to monitor changes and outcomes of your function triggers. This endpoint will show you information about all events that have been processed by the EventGrid trigger function.

## Production Recommendations

### Monitor Function Triggers and Results

```powershell
# View function execution logs
az containerapp logs show --resource-group $RG --name $APP --tail 100 | Select-String "Executed"

# Monitor EventGrid processing results via HTTP endpoint
$FQDN = az containerapp show --name $APP --resource-group $RG --query "properties.configuration.ingress.fqdn" -o tsv
Invoke-RestMethod "https://$FQDN/api/GetEvents"
```

**Key Monitoring Points:**

- **Logs**: Show real-time function execution when EventGrid events are received
- **GetEvents Endpoint**: `https://<FQDN>/api/GetEvents` provides results of all processed EventGrid trigger events
- **Status**: Container app health and running status


## Troubleshooting Checklist

✅ **Container Registry**: Verify ACR credentials and image exists  
✅ **Environment Variables**: Confirm all required variables are set  
✅ **EventGrid Configuration**: Test EventGrid topic and subscription configuration  
✅ **Port Configuration**: Ensure target port matches application port  
✅ **Resource Permissions**: Verify resource group and environment access  
✅ **EventGrid Subscription**: Confirm the EventGrid subscription points to the correct function endpoint  
✅ **Function Monitoring**: Use `https://<FQDN>/api/GetEvents` to verify EventGrid trigger processing  

---
