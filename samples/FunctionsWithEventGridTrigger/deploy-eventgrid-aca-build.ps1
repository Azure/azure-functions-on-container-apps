# Deploy Event Grid Function to Azure Container Apps (using ACR Build)
# This version builds the image in Azure Container Registry instead of locally

param(
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId = "mysubscriptionid",
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "myresourcegroup",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "East US",
    
    [Parameter(Mandatory=$false)]
    [string]$ContainerRegistry = "myacrname",
    
    [Parameter(Mandatory=$false)]
    [string]$AppName = "eventgrid-functions-app",
    
    [Parameter(Mandatory=$false)]
    [string]$Environment = "azure-functions-env"
)

$IMAGE_TAG = "eventgrid-functions:v1.0.0"
$ACR_IMAGE = "$ContainerRegistry.azurecr.io/$IMAGE_TAG"

Write-Host "🚀 Deploying Event Grid Azure Functions to Container Apps" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green

# Step 1: Set Azure subscription
Write-Host "`n1️⃣ Setting Azure subscription..." -ForegroundColor Yellow
try {
    az account set --subscription $SubscriptionId
    $currentSub = az account show --query "name" -o tsv
    Write-Host "Using subscription: $currentSub" -ForegroundColor Green
} catch {
    Write-Host "Failed to set subscription. Please run 'az login' first." -ForegroundColor Red
    exit 1
}

# Step 2: Build image using ACR Build (no local Docker required)
Write-Host "`n2️⃣ Building image using Azure Container Registry..." -ForegroundColor Yellow
try {
    az acr build --registry $ContainerRegistry --image $IMAGE_TAG --file Dockerfile.eventgrid .
    Write-Host "   ✅ Image built in ACR: $ACR_IMAGE" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to build image in ACR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 3: Get ACR credentials
Write-Host "`n3️⃣ Getting ACR credentials..." -ForegroundColor Yellow
try {
    $acrCred = az acr credential show --name $ContainerRegistry --query "{username:username,password:passwords[0].value}" -o json | ConvertFrom-Json
    $ACR_USERNAME = $acrCred.username
    $ACR_PASSWORD = $acrCred.password
    Write-Host "   ✅ ACR credentials retrieved" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to get ACR credentials: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 4: Deploy Container App
Write-Host "`n4️⃣ Deploying Container App..." -ForegroundColor Yellow

# Get storage connection string
$STORAGE_CONN_STRING = "MyStorageConnectionString" # Replace with your actual storage connection string

Write-Host "   🔧 Executing deployment command..." -ForegroundColor Gray
try {
    az containerapp create `
      --name $AppName `
      --resource-group $ResourceGroup `
      --environment $Environment `
      --image $ACR_IMAGE `
      --target-port 80 `
      --ingress external `
      --registry-server "$ContainerRegistry.azurecr.io" `
      --registry-username $ACR_USERNAME `
      --registry-password $ACR_PASSWORD `
      --env-vars "AzureWebJobsStorage=$STORAGE_CONN_STRING" "FUNCTIONS_WORKER_RUNTIME=node" "AzureWebJobsFeatureFlags=EnableWorkerIndexing" "ASPNETCORE_URLS=http://+:80" `
      --kind functionapp
      
    Write-Host "   ✅ Container App deployed successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 5: Get the application URL
Write-Host "`n5️⃣ Getting application endpoints..." -ForegroundColor Yellow
try {
    $APP_URL = az containerapp show --name $AppName --resource-group $ResourceGroup --query "properties.configuration.ingress.fqdn" -o tsv
    Write-Host "   ✅ Application URL: https://$APP_URL" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Could not retrieve application URL" -ForegroundColor Yellow
}

Write-Host "`n🎉 Deployment completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Summary:" -ForegroundColor Cyan
Write-Host "   • Container App: $AppName"
Write-Host "   • Environment: $Environment"
Write-Host "   • Image: $ACR_IMAGE"
Write-Host "   • Resource Group: $ResourceGroup"
Write-Host ""
Write-Host "🔗 Endpoints:" -ForegroundColor Cyan
Write-Host "   • Event Grid Webhook: https://$APP_URL/api/eventGridTrigger"
Write-Host "   • HTTP API (View Events): https://$APP_URL/api/eventGridHttp"
Write-Host ""
Write-Host "🧪 Test your deployment:" -ForegroundColor Cyan
Write-Host "   # Test HTTP endpoint"
Write-Host "   Invoke-WebRequest -Uri `"https://$APP_URL/api/eventGridHttp`""
Write-Host ""
Write-Host "   # Create Event Grid subscription to Resource Group events"
Write-Host "   az eventgrid event-subscription create \"
Write-Host "     --name `"eventgrid-subscription`" \"
Write-Host "     --source-resource-id `"/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup`" \"
Write-Host "     --endpoint `"https://$APP_URL/api/eventGridTrigger`" \"
Write-Host "     --endpoint-type webhook"
Write-Host ""
Write-Host "✅ Your Event Grid Function is ready to receive webhook events!" -ForegroundColor Green