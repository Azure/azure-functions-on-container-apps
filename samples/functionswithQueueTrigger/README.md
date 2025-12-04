# Azure Functions with Dynamic Queue Reader

This sample provides HTTP APIs to dynamically read from Azure Storage queues and list available queues without needing predefined queue triggers. Perfect for scenarios where you need to inspect queues programmatically at runtime.

## 🚀 Features

- **Dynamic Queue Reading** - Read messages from any queue by specifying the queue name at runtime
- **Queue Management** - List all available queues in your storage account
- **Azure Storage Integration** - Works with real Azure Storage accounts
- **Container Apps Ready** - Designed for deployment on Azure Container Apps

## 📋 Prerequisites

- .NET 8.0 or later
- Azure Functions Core Tools (v4.x)
- Azure Storage Account
- Visual Studio Code (optional)

## 🔧 Setup & Configuration

### 1. Get Your Storage Connection String

```bash
# Using Azure CLI
az storage account show-connection-string --name YOUR_STORAGE_ACCOUNT --resource-group YOUR_RESOURCE_GROUP

# Using Azure Portal
# Navigate to Storage Account > Access Keys > Copy connection string
```

### 2. Install Dependencies
```bash
dotnet restore
```

### 3. Build the Project
```bash
dotnet build
```

## 🐳 Deployment to Azure Container Apps

### Prerequisites

- Azure CLI installed and logged in
- Docker installed and running
- Azure Container Registry created
- Azure Storage Account created
- Container Apps environment created

### Step-by-Step Deployment Commands

#### 1. Prepare Your Environment Variables

```bash
# Set your variables (replace with your actual values)
RESOURCE_GROUP="your-resource-group"
CONTAINER_APP_NAME="your-function-app-name"
REGISTRY_NAME="your-container-registry"
REGISTRY_URL="${REGISTRY_NAME}.azurecr.io"
IMAGE_TAG="v1.0.0"
STORAGE_CONNECTION_STRING="DefaultEndpointsProtocol=https;AccountName=YOUR_STORAGE_ACCOUNT;AccountKey=YOUR_KEY;EndpointSuffix=core.windows.net"
ENVIRONMENT_NAME="your-container-apps-environment"
```

#### 2. Build and Push Docker Image

```bash
# Build the Docker image
docker build -t queuereader:latest .

# Tag for your container registry
docker tag queuereader:latest ${REGISTRY_URL}/queuereader:${IMAGE_TAG}

# Login to Azure Container Registry
az acr login --name ${REGISTRY_NAME}

# Push to registry
docker push ${REGISTRY_URL}/queuereader:${IMAGE_TAG}
```

#### 3. Deploy to Container Apps

```bash
# Create the container app with function app configuration
az containerapp create \
    --resource-group ${RESOURCE_GROUP} \
    --name ${CONTAINER_APP_NAME} \
    --environment ${ENVIRONMENT_NAME} \
    --image ${REGISTRY_URL}/queuereader:${IMAGE_TAG} \
    --target-port 80 \
    --ingress external \
    --kind functionapp \
    --registry-server ${REGISTRY_URL} \
    --registry-identity system \
    --cpu 0.25 \
    --memory 0.5Gi \
    --min-replicas 0 \
    --max-replicas 10 \
    --env-vars "AzureWebJobsStorage=${STORAGE_CONNECTION_STRING}" \
               "FUNCTIONS_WORKER_RUNTIME=dotnet-isolated" \
               "AzureWebJobsSecretStorageType=files" \
               "ASPNETCORE_URLS=http://+:80"
```

#### 4. Verify Deployment

```bash
# Get application URL
az containerapp show --resource-group ${RESOURCE_GROUP} --name ${CONTAINER_APP_NAME} --query "properties.configuration.ingress.fqdn" --output tsv

# List available functions
az containerapp function list --resource-group ${RESOURCE_GROUP} --name ${CONTAINER_APP_NAME}

# Get function keys (required for authentication)
az containerapp function keys list --resource-group ${RESOURCE_GROUP} --name ${CONTAINER_APP_NAME} --key-type hostKey
```

## 📡 API Endpoints

### 1. **Read from Queue**
Once messages are published in the Queue. Read messages from any queue by specifying the queue name as a query parameter. Optionally specify the number of messages to read.

**GET Method:**
```bash
GET /api/ReadFromQueue?queueName=myqueue&count=5
```

**Parameters:**
- `queueName` (required) - Name of the queue to read from
- `count` (optional) - Number of messages to read (default: 1, max: 32)

**Response:**
```json
{
  "queueName": "myqueue",
  "messageCount": 2,
  "messages": [
    {
      "messageId": "abc123",
      "messageText": "Hello World!",
      "insertionTime": "2024-12-03T10:00:00Z",
      "expirationTime": "2024-12-10T10:00:00Z"
    }
  ],
  "timestamp": "2024-12-03T10:05:00Z"
}
```

### 2. **List All Queues**
Get a list of all queues in your storage account.

```bash
GET /api/ListQueues
```

**Response:**
```json
{
  "queues": ["myqueue", "testqueue", "samplequeue"],
  "count": 3,
  "timestamp": "2024-12-03T10:05:00Z"
}
```

## 🧪 API Testing

### Production Testing (Container Apps)

**⚠️ Important:** All deployed functions require function keys for authentication.

### Testing with curl

Replace `YOUR_CONTAINER_APP_URL` with your actual Container Apps URL.

**List all queues:**
```bash
curl "https://YOUR_CONTAINER_APP_URL/api/listqueues?code=YOUR_FUNCTION_KEY"
```

**Read messages from a queue:**
```bash
curl "https://YOUR_CONTAINER_APP_URL/api/readfromqueue?queueName=testqueue&count=5&code=YOUR_FUNCTION_KEY"
```



### Advanced Testing Examples

**Using variables with curl:**

```bash
# Set your variables
BASE_URL="https://YOUR_CONTAINER_APP_URL"
FUNCTION_KEY="YOUR_FUNCTION_KEY"

# List all queues
curl "${BASE_URL}/api/listqueues?code=${FUNCTION_KEY}"

# Read messages from queue (with count parameter)
curl "${BASE_URL}/api/readfromqueue?queueName=testqueue&count=10&code=${FUNCTION_KEY}"

```

## 🔑 Function Key Management

### Get Function Keys

```bash
# Get host keys (work for all functions)
az containerapp function keys list \
    --resource-group YOUR_RESOURCE_GROUP \
    --name YOUR_CONTAINER_APP_NAME \
    --key-type hostKey

# Get function-specific keys
az containerapp function keys list \
    --resource-group YOUR_RESOURCE_GROUP \
    --name YOUR_CONTAINER_APP_NAME \
    --function-name ReadFromQueue \
    --key-type functionKey
```

### Create Custom Keys

```bash
# Create a custom host key
az containerapp function keys set \
    --resource-group YOUR_RESOURCE_GROUP \
    --name YOUR_CONTAINER_APP_NAME \
    --key-name "myCustomKey" \
    --key-value "your-custom-key-value" \
    --key-type hostKey
```

## 🔍 Troubleshooting

### Common Issues

1. **Authentication Required (401 Unauthorized)**
   - All deployed functions require function keys
   - See **Function Key Management** section for key retrieval
   - Add `?code=YOUR_FUNCTION_KEY` to all requests

2. **Storage Connection Errors**
   - Verify your connection string is correct
   - Ensure the storage account exists and is accessible

3. **Function Not Starting**
   - Check that .NET 8.0 is installed
   - Verify Azure Functions Core Tools v4.x is installed

4. **Queue Not Found**
   - Check queue name spelling and case sensitivity
   - Ensure the queue exists in your storage account

5. **Container Registry Access**
   - Ensure registry credentials are correct
   - Use `--registry-identity system` for managed identity authentication

## 🔗 Useful Links

- [Azure Container Apps Documentation](https://docs.microsoft.com/azure/container-apps/)
- [Azure Functions on Container Apps](https://learn.microsoft.com/azure/container-apps/functions-usage)
- [Azure Storage Queues Documentation](https://docs.microsoft.com/azure/storage/queues/)
- [Function Keys Management](https://learn.microsoft.com/azure/container-apps/functions-usage#manage-functions)

