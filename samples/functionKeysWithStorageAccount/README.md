# Function Keys With Storage Account

This project is a Node.js Azure Functions app with HTTP trigger deployed to Azure Container Apps. It includes dual endpoints (authenticated and anonymous) with Azure Storage for function key management.

More details on function keys and operations are found here: [Use Azure Functions in Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/functions-usage?pivots=azure-cli#manage-functions)

## Deployment Details

- **Function App Name:** `<your-function-app-name>`
- **URL:** `https://<your-function-app-name>.<your-environment-domain>.azurecontainerapps.io/`
- **Container Registry:** `<your-container-registry>.azurecr.io`
- **Image:** `<your-image-name>:<tag>`
- **Storage Account:** `<your-storage-account>`

## Endpoints

1. **Anonymous Health Check:** `/api/health` - No authentication required
2. **Authenticated Function:** `/api/httpTrigger` - Requires function key

## Function Key

- **Default Host Key:** `<your-generated-function-key>`
- **Usage:** Add `?code=<key>` to authenticated endpoint URLs

## Azure Container Apps Deployment

1. **Get storage account connection string:**
   ```bash
   # Get the storage account connection string
   az storage account show-connection-string \
     --name <your-storage-account> \
     --resource-group <your-resource-group> \
     --query connectionString \
     --output tsv
   ```

2. **Build and push container:**
   ```bash
   # Build the Docker image
   docker build -t <your-container-registry>.azurecr.io/<your-image-name>:latest .
   
   # Push to registry
   docker push <your-container-registry>.azurecr.io/<your-image-name>:latest
   ```

3. **Deploy to Container Apps:**
   ```bash
   az containerapp create \
     --resource-group <your-resource-group> \
     --name <your-function-app-name> \
     --environment <your-container-apps-environment> \
     --image <your-container-registry>.azurecr.io/<your-image-name>:<tag> \
     --target-port 80 \
     --ingress external \
     --kind functionapp \
     --registry-server <your-container-registry>.azurecr.io \
     --registry-identity system \
     --env-vars "AzureWebJobsStorage=DefaultEndpointsProtocol=https;AccountName=<your-storage-account>;AccountKey=<storage-key>;EndpointSuffix=core.windows.net" "FUNCTIONS_WORKER_RUNTIME=node" "AzureWebJobsSecretStorageType=files"
   ```

## Getting Started with Function Keys

### Step 1: Discover Available Functions

First, list all functions in your container app to see what's available:

```bash
az containerapp function list \
  --resource-group <your-resource-group> \
  --name <your-function-app-name>
```

### Step 2: Get Function Details and Endpoints

Get detailed information about specific functions to see their trigger URLs and configuration:

```bash
az containerapp function show \
  --resource-group <your-resource-group> \
  --name <your-function-app-name> \
  --function-name <function-name>
```

This command will show you:

- Function trigger URL
- Trigger type (HTTP, Timer, etc.)
- Function configuration
- Authorization level

### Step 3: Get Function Keys

Retrieve the function keys for authentication:

```bash
az containerapp function keys list \
  --resource-group <your-resource-group> \
  --name <your-function-app-name> \
  --key-type hostKey
```

### Step 4: Test the Endpoints

Using the URLs from the function show command and the keys from the previous step, test your endpoints:

**Test anonymous endpoint (no key required):**

```bash
curl https://<your-function-app-name>.<your-environment-domain>.azurecontainerapps.io/api/health
```

**Test authenticated endpoint (requires function key):**

```bash
curl "https://<your-function-app-name>.<your-environment-domain>.azurecontainerapps.io/api/httpTrigger?code=<your-generated-function-key>"
```

### Step 5: Explore Advanced Key Management

After testing the endpoints, explore additional key management operations:

## Function Key Management Operations

Azure Container Apps provides comprehensive key management capabilities for your Functions app. Here are the available operations:

### List All Keys

List all host-level keys for your function app:

```bash
az containerapp function keys list \
  --resource-group <your-resource-group> \
  --name <your-function-app-name> \
  --key-type hostKey
```

### Show a Specific Key

Display the value of a specific host-level key:

```bash
az containerapp function keys show \
  --resource-group <your-resource-group> \
  --name <your-function-app-name> \
  --key-name <key-name> \
  --key-type hostKey
```

### Set/Create a New Key

Create or update a specific host-level key with a custom value:

```bash
az containerapp function keys set \
  --resource-group <your-resource-group> \
  --name <your-function-app-name> \
  --key-name <key-name> \
  --key-value <key-value> \
  --key-type hostKey
```

### Function-Specific Keys

To manage keys for a specific function, add the `--function-name` parameter:

```bash
# List function-specific keys
az containerapp function keys list \
  --resource-group <your-resource-group> \
  --name <your-function-app-name> \
  --function-name <function-name> \
  --key-type functionKey

# Show a specific function key
az containerapp function keys show \
  --resource-group <your-resource-group> \
  --name <your-function-app-name> \
  --function-name <function-name> \
  --key-name <key-name> \
  --key-type functionKey

# Set a function-specific key
az containerapp function keys set \
  --resource-group <your-resource-group> \
  --name <your-function-app-name> \
  --function-name <function-name> \
  --key-name <key-name> \
  --key-value <key-value> \
  --key-type functionKey
```

### Key Types

- **hostKey**: Access any function in the app
- **functionKey**: Access specific functions only
- **masterKey**: Provide administrative access (available in some scenarios)
- **systemKey**: Used by Azure services

### Key Management Tips

- Keep a minimum of one replica running for key management commands to work properly
- Function keys are automatically generated, stored in Azure Storage and managed by the platform
- Use descriptive names for custom keys to make management easier