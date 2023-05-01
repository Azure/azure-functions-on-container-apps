## Azure Functions on Azure Container Apps (Private Preview) ![image](https://user-images.githubusercontent.com/45637559/229790891-e36169d8-1cd3-497b-85e2-982874ef6584.png)

Azure functions on container apps  helps developers to quickly build event driven, cloud native apps, with the flexibility to run functions along with other microservices, APIs, websites,  workflows or any container hosted programs. You can leverage functions programming model and write code using your preferred programming language or framework that Azure functions supports . You will also get the triggers, bindings and get that first class event driven, cloud native experience. Azure Functions is running on the platform service powered by Azure Container Apps  to run microservices in containers without managing infrastructure. Container Apps Environment is built on a foundation of powerful open-source technology. Behind the scenes, every container app runs on Azure Kubernetes Service, enables to build microservices with full support for Distributed Application Runtime (Dapr) and scale dynamically based on HTTP traffic or events powered by Kubernetes Event-Driven Autoscaling (KEDA). 

Azure Functions on Container Apps Environment offers Azure client tools  and DevOps tooling to provide  seamless experience. This means simplified client tooling features will be enabled with Portal/AzCLI/CICD tools - Azure Pipelines/GitHub Actions. Network and observability configurations  are mapped at Container App Environment so users define these settings at container app environment level which applies to all microservices , functions running as container apps.
-  **Polyglot App Management** : The environment enables to easily integrate mixed workloads - polyglot and heterogeneous modern apps or microservices consisting of webapps hosted on Azure Container Apps, Azure Spring apps, APIs, websites or any container hosted programs along side with Functions besides  providing unified networking, observability, dynamic scaling, configuration, and high productivity
-  **Enable cloud-native capabilities** such as service discovery, native container support, and integration with open source libraries and frameworks like KEDA, Dapr, Envoy
-  **Simplified and seamless client and Devops tooling experiences**  across Azure Portal, Az CLI, Azure Pipelines, GitHub Actions
-  **Dedicated Networking, Observability and pricing plans** tied to Container App environment as opposed to a single app types


## Scenarios
Here are usecases and  scenarios that can be deployed on to Azure Functions on Azure Container Apps

-  React to events from Http/Kafka/Event hubs/Service Bus/Storage Queue and invoke another web or spring based API running in the Container App environment.               Scale on-demand as the events increase
-  Web Services – Rest APIs backend with event based execution requirements or Authentication APIs which trigger during login or authorization events
-  Event based data ingestion platform to perform  data quality checks for online retail/e-commerce/travel apps. This process helps validating  data for data accuracy, data completeness etc. ML workflows get invoked once data quality processing completes
-  Mixed workloads across different app types. Easy integration across other application types like Azure Container Apps and Azure Spring Apps
-  IoT/Point-Of-Sales/Edge event processing microservices applications

## Key Features of Azure Functions on Container App Environment

Functions on Container App environment is designed to meet the needs of cloud-native requirements, while preserving approachability for teams of all sizes and capabilities. It provides unified platform with portability, flexibility, and  developer-centric entry points for building apps
-  **Integrated Azure Functions Programming model** and write code using your preferred programming language or framework that Azure functions supports 
-  **Consistent end to end development experiences** across Azure functions plans and hosting options using inner loop, outer loop, runtime and DevOps tooling
-  **Build multi type apps** and easily integrate with multiple app types for a microservices design like run functions along with other microservices, APIs, websites,  workflows or any container hosted programs
-  **Scale dynamically based on events** all the way to zero or scale to dozens of containers when under high load

## Triggers and Bindings that would be available in Private preview 

-  Http 
-  Azure Storage Queue
-  Azure Service Bus
-  Azure EventHub
-  Kafka Trigger

## Azure Regions 

-  North Europe

## Create your first Azure Function on Azure Container Apps
## In this section:
-  [**Prerequisites**](https://github.com/Azure/azure-functions-on-container-apps/blob/main/README.md#prerequisites)
-  [**Create a local function project**](https://github.com/Azure/azure-functions-on-container-apps/blob/main/README.md#create-the-local-function-project-c-isolated---http-trigger)
-  [**Build, Test and Push the container image**](https://github.com/Azure/azure-functions-on-container-apps/blob/main/README.md#build-the-container-image-and-test-locally)
-  [**Create Azure resources**](https://github.com/Azure/azure-functions-on-container-apps/blob/main/README.md#create-azure-resources)
-  [**Invoke the function on Azure** ](https://github.com/Azure/azure-functions-on-container-apps/blob/main/README.md#invoke-the-function-on-azure)
-  [**Next Steps**](https://github.com/Azure/azure-functions-on-container-apps/blob/main/README.md#next-steps)

## Prerequisites

**On Your Local computer**

|     C# Isolated                                                                                                                                                                                                                  |     Node                                  |     Python                                                            |     Java                                                                                                                                                                                                              |     PowerShell                                     |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------|-----------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------|
|     [.NET   6.0 SDK.](https://dotnet.microsoft.com/download) or [.NET 7.0 SDK](https://dotnet.microsoft.com/en-us/download/dotnet/7.0) when targeting .NET 7.0., [Docker](https://docs.docker.com/install/), [Docker ID](https://hub.docker.com/signup) OR [Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-portal?tabs=azure-cli) (You must  have Docker installed locally. Docker   provides packages that easily configure Docker on any [Mac], Windows, or Linux system.) |[Node.js](https://nodejs.org/) version 18 or above.         |[Python versions that are supported by Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/supported-languages#languages-by-runtime-version)          |The [Java Developer Kit](https://learn.microsoft.com/en-us/azure/developer/java/fundamentals/java-support-on-azure), version 8 or 11. The JAVA\_HOME environment variable must be set to the install location of the correct version of the JDK.[Apache Maven](https://maven.apache.org/), version 3.0 or above |The [.NET 6.0 SDK](https://dotnet.microsoft.com/download)[PowerShell 7.2](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows)|
|[Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local#v2) version 4.x.| [Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local#v2) version 4.x.|[Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local#v2) version 4.x.|[Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local#v2) version 4.x.|[Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local#v2) version 4.x.|
|[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) [version 2.4](https://learn.microsoft.com/en-us/cli/azure/release-notes-azure-cli#april-21-2020) or later.|[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) [version 2.4](https://learn.microsoft.com/en-us/cli/azure/release-notes-azure-cli#april-21-2020) or later.|[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) [version 2.4](https://learn.microsoft.com/en-us/cli/azure/release-notes-azure-cli#april-21-2020) or later.|[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) [version 2.4](https://learn.microsoft.com/en-us/cli/azure/release-notes-azure-cli#april-21-2020) or later.|[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) [version 2.4](https://learn.microsoft.com/en-us/cli/azure/release-notes-azure-cli#april-21-2020) or later.|
| You also need an Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/free/?ref=microsoft.com&utm_source=microsoft.com&utm_medium=docs&utm_campaign=visualstudio).| You also need an Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/free/?ref=microsoft.com&utm_source=microsoft.com&utm_medium=docs&utm_campaign=visualstudio).| You also need an Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/free/?ref=microsoft.com&utm_source=microsoft.com&utm_medium=docs&utm_campaign=visualstudio).| You also need an Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/free/?ref=microsoft.com&utm_source=microsoft.com&utm_medium=docs&utm_campaign=visualstudio).| You also need an Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/free/?ref=microsoft.com&utm_source=microsoft.com&utm_medium=docs&utm_campaign=visualstudio).|


Note: extension bundle version compatible with host version 4.17+ can be
used

**Prerequisite check**

Verify your prerequisites, which depend on whether you\'re using Azure CLI for creating Azure resources:
**Azure CLI**
-  In a terminal or command window, run func --version to check that the Azure Functions Core Tools are version 4.x.
-  Run dotnet --list-sdks to check that the required versions are installed.
-  Run az --version to check that the Azure CLI version is 2.4 or later
-  Run az login to sign in to Azure and verify an active subscription.
-  [Docker](https://docs.docker.com/install/) is installed, have a [Docker ID](https://hub.docker.com/signup) and Docker is started

## **Create the local function project C# isolated - Http Trigger**


1\. Run the func init command, as follows, to create a functions project in a folder named *LocalFunctionProj* with the specified runtime:
Below sample built for .NET 7

```sh
func init LocalFunctionProj --worker-runtime dotnet-isolated --docker --target-framework net7.0
```

The \--docker option generates a Dockerfile for the project, which defines a suitable custom container for use with Azure Functions and the selected runtime.

2\. Navigate into the project folder

```sh
cd LocalFunctionProj
```
This folder contains the Dockerfile and other files for the project, including configurations files named [local.settings.json](https://learn.microsoft.com/en-us/azure/azure-functions/functions-develop-local#local-settings-file) and [host.json](https://learn.microsoft.com/en-us/azure/azure-functions/functions-host-json).
By default, the *local.settings.json* file is excluded from source control in the *.gitignore* file. This exclusion is because the file can contain secrets that are downloaded from Azure.

3\. Open the Dockerfile to include following (Usually found in Line 13)

> FROM mcr.microsoft.com/azure-functions/dotnet-isolated:4-dotnet-isolated7.0

> This version of the base image supports Azure Functions deployment to an Azure Container Apps service check to include below as well in the Dockerfile (found in Line 1)
> FROM mcr.microsoft.com/dotnet/sdk:7.0 AS installer-env 

Sample Dockerfile for .NET 7
```sh
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS installer-env

# Build requires 3.1 SDK
COPY --from=mcr.microsoft.com/dotnet/core/sdk:3.1 /usr/share/dotnet /usr/share/dotnet

COPY . /src/dotnet-function-app
RUN cd /src/dotnet-function-app && \
    mkdir -p /home/site/wwwroot && \
    dotnet publish *.csproj --output /home/site/wwwroot

# To enable ssh & remote debugging on app service change the base image to the one below
# FROM mcr.microsoft.com/azure-functions/dotnet-isolated:3.0-dotnet-isolated5.0-appservice
FROM mcr.microsoft.com/azure-functions/dotnet-isolated:4-dotnet-isolated7.0
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true

COPY --from=installer-env ["/home/site/wwwroot", "/home/site/wwwroot"]
```

4\. Add a function to your project by using the following command, where the --name argument is the unique name of your function (HttpExample) and the                     --template argument specifies the function\'s trigger (HTTP).

```sh
func new --name HttpExample --template "HTTP trigger" --authlevel "anonymous"
```

## Build the container image and Test locally

The Dockerfile in the project root describes the minimum required environment to run the function app in a container. The complete list of supported base images for Azure Functions is documented above as **Host images** in the pre-requisites section or can be found in the [Azure Functions Base by Microsoft \| Docker
Hub](https://hub.docker.com/_/microsoft-azure-functions-base)

> **Build and Push using Docker:**

1\. In the root project folder, run the [docker build](https://docs.docker.com/engine/reference/commandline/build/) command, and provide a name, azurefunctionsimage, and tag, v1.0.0.
> Note: Please make sure docker is running in your local
The following command builds the Docker image for the container.
```sh
docker build --tag <DOCKER_ID>/azurefunctionsimage:v1.0.0 .
```

In this example, replace \<DOCKER_ID\> with your Docker Hub account ID. When the command completes, you can run the new container locally.

2\. To test the build, run the image in a local container using the [docker run](https://docs.docker.com/engine/reference/commandline/run/) command, with the adding the ports argument, -p 8080:80.
```sh
docker run -p 8080:80 -it <docker_id>/azurefunctionsimage:v1.0.0
```
Again, replace <DOCKER_ID with your Docker ID and adding the ports argument, -p 8080:80

3\. After the image is running in a local container, browse to http://localhost:8080/api/HttpExample?name=Functions, which should display the same "hello" message as before. Because the HTTP triggered function uses anonymous authorization, you can still call the function even though it\'s running in the container. Function access key settings are enforced when running locally in a container. If you have problems calling the function, make sure that [access to the function](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-http-webhook-trigger#authorization-keys) is set to anonymous.

4\. After you've verified the function app in the container, stop docker with **Ctrl**+**C**.

Docker Hub is a container registry that hosts images and provides image and container services. To share your image, which includes deploying to Azure, you must push it to a registry.
**Docker login**

5\.  If you haven\'t already signed in to Docker, do so with the [docker login](https://docs.docker.com/engine/reference/commandline/login/) command, replacing  <docker_id> with your Docker ID. This command prompts you for your username and password. A "Login Succeeded" message confirms that you\'re signed in.

6\. After you\'ve signed in, push the image to Docker Hub by using the [docker push](https://docs.docker.com/engine/reference/commandline/push/) command, again replacing <docker_id> with your Docker ID.
```sh
docker push <docker_id>/azurefunctionsimage:v1.0.0
```
 7\. Depending on your network speed, pushing the image the first time might take a few minutes (pushing subsequent changes is much faster). While you\'re waiting, you can proceed to the next section and create Azure resources in another terminal.

> **Build and Push using ACR (Optional Azure Container Registry)**

You can build and deploy functions on Azure container apps using ACR as well. Please make sure you have an [ACR](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-portal?tabs=azure-cli) repository created by following the steps mentioned in the link. Azure Container Registry is a private registry service for building, storing,and managing container images and related artifacts.

1\. Login to the registry

Before pushing and pulling container images, you must log in to the registry. To do so, use the [az acr login](https://learn.microsoft.com/enus/cli/azure/acr#az_acr_login) command. Specify only the registry resource name when logging in with the Azure CLI. Don\'t use the fully qualified login server name.

```sh
az acr login --name <registry-name>
```

2\. Build and Push to the registry

Before you can push an image to your registry, you must tag it with the fully qualified name of your registry login server. The login server name is in the format *\<registry-name\>.azurecr.io* (must be all lowercase), for example, *mycontainerregistry.azurecr.io*.
Tag the image using the [docker tag](https://docs.docker.com/engine/reference/commandline/tag/) command.
Replace <login-server> with the login server name of your ACR instance.

```sh
  docker tag <docker_id>/azurefunctionsimage:v1.0.0 <login-server>/azurefunctionsimage:v1
  ```

The following command builds the image, and pushes it to your container registry if the build is successful.

```sh
  az acr build --registry $ACR_NAME --image azurefunctionsimage:v1 .
```

## Create Azure resources

Before you can deploy your container to your Azure Container apps you need to create two more resources

a\. A [Storage account](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-create). 

b\. Create the Container Apps environment with a Log Analytics workspace

1\. Login to your Azure subscription

```sh 
az login
  
az account set -subscription | -s <subscription_name>

az upgrade

az extension add --name containerapp --upgrade

az provider register --namespace Microsoft.Web

az provider register --namespace Microsoft.App

az provider register --namespace Microsoft.OperationalInsights
```
---

2\. Create azure container app environment

Create an environment with an auto-generated Log Analytics workspace.

```sh
  az group create --name MyResourceGroup --location northeurope
  az containerapp env create -n MyContainerappEnvironment -g MyResourceGroup --location northeurope
  ```
3\.  Create Storage account

Use the [az storage account create](https://learn.microsoft.com/en-us/cli/azure/storage/account#az-storage-account-create) command to create a general-purpose storage account in your resource group and region:

```sh
az storage account create --name <STORAGE_NAME> --location northeurope --resource-group MyResourceGroup --sku Standard_LRS
  ```
Replace <STORAGE_NAME> with a name that is appropriate to you and unique in Azure Storage. Names must contain three to 24 characters numbers and lowercase letters only. Standard_LRS specifies a general-purpose account, which is [supported by Functions](https://learn.microsoft.com/en-us/azure/azure-functions/storage considerations#storage-account-requirements). The --location value is a standard Azure region.

## Create the function app
 
 Run the [az functionapp create](https://learn.microsoft.com/en-us/cli/azure/functionapp#az-functionapp-create) command to create a new function app in the new managed environment backed by azure container apps.
 

> Note: **If you wish to use the quick start demo Http trigger sample you can include the below image url for --image parameter(this is a
publicly accessible image so username/password is not required) 
---
```sh  
azurefunctionstest.azurecr.io/azure-functions/dotnet7-quickstart-demo:1.0
  ```
---
    
> OR you may keep the image url ready for an existing image that you have in your repo which is already "build" 
    for eg: <hub-user>/<repo-name>:<tag> ->  mydockerusr/azurefunctionsimage:v2
    
> Using Docker Hub
  ---
```sh
az functionapp create --resource-group MyResourceGroup --name <functionapp_name> \
--environment MyContainerappEnvironment \
--storage-account <Storage_name> \
--functions-version 4 \
--runtime dotnet-isolated \
--image <DOCKER_ID>/<image_name>:<version> 
```
> Using ACR
---    
```sh
az functionapp create --resource-group MyResourceGroup --name <functionapp_name> \
--environment MyContainerappEnvironment \
--storage-account <Storage_name> \
--functions-version 4 \
--runtime dotnet-isolated \
--image <acr login-server>/<image_name>:<version> \
--registry-username <user_name> --registry-password <user_password>
  ```
 ---

In this example, replace **MyContainerappEnvironment** with the Azure container apps environment name. Also, replace <STORAGE_NAME> with the name of the account you used in the previous step, <APP_NAME> with a globally unique name appropriate to you, and <DOCKER_ID> or <login-server> with your Docker Hub ID or ACR , <user_name> with the username to log in to container registry(mostly applicable for ACR) and <user_password> with the password to log in to container registry. If
stored as a secret, value must start with 'secretref:' followed by the secret name (mostly applicable for ACR).

The *--image* parameter specifies the image to use for the function app. You can use the [az functionapp config container show](https://learn.microsoft.com/en-us/cli/azure/functionapp/config/container#az-functionapp-config-container-show) command to view information about the image used for deployment. You can also use the [az functionapp config container set](https://learn.microsoft.com/en-us/cli/azure/functionapp/config/container#az-functionapp-config-container-set) command to deploy from a different image.

When you first create the function app, it pulls the initial image from your Docker Hub. You can also [Enable continuous deployment to Azure](https://learn.microsoft.com/en-us/azure/azure-functions/functions-create-function-linux-custom-image#enable-continuous-deployment-to-azure) from Docker Hub.

**Set required app settings**

Run the following commands to create an app setting for the storage account connection string:
```sh
az storage account show-connection-string --resource-group <Resource_group> --name <STORAGE_NAME> --query connectionString --output tsv
 ```
Copy the output of the above and replace below at <storageConnectionString>
    
```sh
az functionapp config appsettings set --name <app_name> --resource-group <Resource_group> --settings AzureWebJobsStorage=<storageConnectionString>
```

## Invoke the function on Azure

Because your function uses an HTTP trigger, you invoke it by making an HTTP request to its URL in the browser or with a tool like curl.
Execute below command to get the Invoke URL
    
```sh
az functionapp function show -g <Resource_group> -n  <function_app_name>  --function-name <http_funtion_name> --query "invokeUrlTemplate" --output tsv
```
  
Copy the complete **Invoke URL** shown in the output of the publish command into a browser address bar, appending the query parameter ?name=functions or copy the Application Url and append /api/HttpExample?name=HelloWorld. The browser should display similar output as when you ran the function locally.
> For eg: The Url generated would be - http://myfuncapponaca.gray-a2b3ceef.northeurope.azurecontainerapps.io/api/httpexample

## Update function container image

If you wish you make changes to your code, modify the image with new version tag and build it, and then finally update the function's container app image please use below command. 
Note: Below sample for docker hub based image

```sh
az functionapp config container set --image-name <ImageName> --registry-password <Password>  --registry-username <DockerUserId> --name <MyFunctionApp> --resource-group <MyResourceGroup>
```

## Clean up resources

If you\'re not going to continue on to the next sample function app, you can remove the Azure resources created during this quickstart with the following command.

** Caution**

The following command deletes the specified resource group and all resources contained within it. If the group contains resources outside the scope of this quickstart, they are also deleted.

```sh
 az group delete --name $RESOURCE_GROUP
 ```

** Tip**

Having issues? Let us know on GitHub by opening an issue [here](https://github.com/Azure/azure-functions-on-container-apps/issues)

## Next steps

-   Congratulations!! you have completed deploying your function app
    running in a azure container apps you can connect it to [Azure
    Storage by adding a Queue Storage output binding](https://learn.microsoft.com/en-us/azure/azure-functions/functions-add-output-binding-storage-queue-cli?pivots=programming-language-csharp&tabs=in-process%2Cv1%2Cbash%2Cbrowser) or Azure Service Bus or Azure EventHub or Kafka Trigger
    

 ## TroubleShooting 
Having issues with creating Azure Functions on Azure Container apps please refer to the [troubleshooting guide](https://github.com/Azure/azure-functions-on-container-apps/blob/main/Troubleshooting%20Guide.md)


## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
