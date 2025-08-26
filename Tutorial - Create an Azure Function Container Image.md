
# Create an Azure Function Container Image for Azure Container Apps hosting

This tutorial shows you how to create and test a containerized Azure Function that can be deployed to Azure Container Apps. You'll build a working container image locally and verify it functions correctly before creating Azure resources.

> **Note**: If you encounter any issues with the steps in this tutorial, refer to the [official Azure Functions container documentation](https://learn.microsoft.com/en-us/azure/azure-functions/functions-create-container-registry) for the most up-to-date information, as the public documentation is updated more frequently.

## In this tutorial

- [Prerequisites](#prerequisites)
- [Create a local function project](#create-a-local-function-project)
- [Build and test the container image](#build-and-test-the-container-image)
- [Push the image to a container registry](#push-the-image-to-a-container-registry)

## Prerequisites

Before you begin, ensure you have the following installed on your local development machine:

### Required tools

- **Docker Desktop**: [Install Docker](https://docs.docker.com/install/) and ensure it's running
- **Azure Functions Core Tools**: Version 4.x or later
- **Azure CLI**: Version 2.47 or later
- **Container Registry**: Either a [Docker Hub account](https://hub.docker.com/signup) or an [Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-portal?tabs=azure-cli)
- **Azure subscription**: [Create a free account](https://azure.microsoft.com/free/?ref=microsoft.com&utm_source=microsoft.com&utm_medium=docs&utm_campaign=visualstudio) if you don't have one

### Language-specific requirements

Choose the requirements for your preferred programming language:

| Language | Requirements |
|----------|-------------|
| **C# Isolated** | [.NET 8.0 SDK](https://dotnet.microsoft.com/en-us/download/dotnet/8.0), [.NET 7.0 SDK](https://dotnet.microsoft.com/en-us/download/dotnet/7.0), or [.NET 6.0 SDK](https://dotnet.microsoft.com/download) |
| **Node.js** | [Node.js](https://nodejs.org/) version 18 or above |
| **Python** | [Python versions supported by Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/supported-languages#languages-by-runtime-version) |
| **Java** | [Java Developer Kit](https://learn.microsoft.com/en-us/azure/developer/java/fundamentals/java-support-on-azure) version 8 or 11, [Apache Maven](https://maven.apache.org/) version 3.0 or above |
| **PowerShell** | [.NET 6.0 SDK](https://dotnet.microsoft.com/download), [PowerShell 7.2](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows) |

### Verify prerequisites

Run the following commands to verify your environment is configured correctly:

```bash
# Check Azure Functions Core Tools version
func --version

# Check Azure CLI version
az --version

# Sign in to Azure
az login

# Verify Docker is running
docker --version
```

For C# development, also verify the .NET SDK:

```bash
dotnet --list-sdks
```

## Create a local function project

### Step 1: Initialize the function project

Create a new Azure Functions project with Docker support. This example uses C# isolated process with .NET 7.0:

```bash
func init LocalFunctionProj --worker-runtime dotnet-isolated --docker --target-framework net7.0
```

The `--docker` option generates a `Dockerfile` that defines the container configuration for your function app.

### Step 2: Navigate to the project folder

```bash
cd LocalFunctionProj
```

The project folder contains:
- **Dockerfile**: Defines the container image configuration
- **local.settings.json**: Stores app settings and connection strings for local development
- **host.json**: Contains global configuration options for the function host

> **Note**: The `local.settings.json` file is excluded from source control by default as it may contain sensitive information.

### Step 3: Update the Dockerfile

Open the `Dockerfile` and ensure it uses the correct base images for Azure Container Apps compatibility:

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS installer-env

COPY . /src/dotnet-function-app
RUN cd /src/dotnet-function-app && \
    mkdir -p /home/site/wwwroot && \
    dotnet publish *.csproj --output /home/site/wwwroot

FROM mcr.microsoft.com/azure-functions/dotnet-isolated:4-dotnet-isolated7.0
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true

COPY --from=installer-env ["/home/site/wwwroot", "/home/site/wwwroot"]
```

### Step 4: Update project configuration (for .NET 7.0)

If using .NET 7.0, update the `.csproj` file to target the correct framework:

```xml
<TargetFramework>net7.0</TargetFramework>
```

### Step 5: Add an HTTP trigger function

Create a new HTTP-triggered function with anonymous authentication:

```bash
func new --name HttpExample --template "HTTP trigger" --authlevel "anonymous"
```

## Build and test the container image

### Step 1: Build the Docker image

From the project root directory, build the container image:

```bash
docker build --platform linux --tag <DOCKER_ID>/azurefunctionsimage:v1.0.0 .
```

Replace `<DOCKER_ID>` with your Docker Hub account ID.

### Step 2: Run the container locally

Test your function by running the container:

```bash
docker run -p 8080:80 -it <DOCKER_ID>/azurefunctionsimage:v1.0.0
```

### Step 3: Test the function

Open your browser and navigate to:

```
http://localhost:8080/api/HttpExample?name=Functions
```

You should see a response confirming your function is working. Since the function uses anonymous authorization, no access keys are required.

### Step 4: Stop the container

Press **Ctrl+C** to stop the running container.

## Push the image to a container registry

Choose one of the following options to store your container image:

### Option 1: Push to Docker Hub

1. **Sign in to Docker Hub**:
   ```bash
   docker login
   ```
   Enter your Docker Hub username and password when prompted.

2. **Push the image**:
   ```bash
   docker push <DOCKER_ID>/azurefunctionsimage:v1.0.0
   ```

### Option 2: Push to Azure Container Registry

1. **Sign in to your Azure Container Registry**:
   ```bash
   az acr login --name <REGISTRY_NAME>
   ```
   Use only the registry name, not the full login server URL.

2. **Tag the image for ACR**:
   ```bash
   docker tag <DOCKER_ID>/azurefunctionsimage:v1.0.0 <REGISTRY_NAME>.azurecr.io/azurefunctionsimage:v1.0.0
   ```

3. **Build and push to ACR** (alternative method):
   ```bash
   az acr build --registry <REGISTRY_NAME> --image azurefunctionsimage:v1.0.0 .
   ```
   This command builds the image in Azure and automatically pushes it to your registry.

## Next steps

Your containerized Azure Function is now ready for deployment. The image is stored in your container registry and can be deployed to Azure Container Apps.

> **Important**: Always test your function locally in a container before deploying to Azure to minimize debugging efforts in the cloud environment.

