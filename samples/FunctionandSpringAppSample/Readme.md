# Real-time event processing with Azure Functions, Azure Spring Apps and Azure Service Bus

This sample consists of function app and another microservice such as java app hosted on spring apps service. These are deployed to same container app environment.
In a nutshell  a spring app is subscribed to a Azure Service bus queue lower-case. It reads the message from lower-case queue , converts the message to uppercase and publishes this to an upper case queue. To make the app simple, message processing just converts the message to uppercase. On publishing the message to upper-case queue function app which is subscribed to service bus queue is triggered to read the message from the uppercase queue.
The following diagram depicts this process:

![image](https://github.com/Azure/azure-functions-on-container-apps/assets/45637559/bf0c370f-d747-470a-8e87-39a59e87e1ca)

# Prerequisites

An Azure subscription. If you don't have a subscription, create a free [account](https://azure.microsoft.com/free/) before you begin.
[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli). Version 2.49.0 or greater.
[Git](https://git-scm.com/downloads).
The [.NET 7 SDK](https://dotnet.microsoft.com/download).
[Azure Functions Core Tools version 4.x](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local#v2).
[Java Development Kit (JDK)](https://learn.microsoft.com/en-us/java/azure/jdk/), version 17.
To publish the containerized function app image you create to a container registry, you need a Docker ID and [Docker](https://docs.docker.com/install/) running on your local computer. If you don't have a Docker ID, you can [create a Docker account](https://hub.docker.com/signup).
For Azure Container Registry - You also need to complete the [Create a container registry](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-portal#create-a-container-registry) section of the Container Registry quickstart to create a registry instance. Make a note of your fully qualified login server name.

# Configure the project
## Deploy Function app

```sh
cd FuncServiceBus
docker build --tag <DOCKER_ID>/<imagename>:v1.0.0 .
docker login
docker push <DOCKER_ID>/<imagename>:v1.0.0

az login
az upgrade

az extension add --name containerapp --upgrade -y
az provider register --namespace Microsoft.Web 
az provider register --namespace Microsoft.App 
az provider register --namespace Microsoft.OperationalInsights
az extension add --name spring
az provider register --namespace Microsoft.AppPlatform

az group create --name MicroservicesContainers-rg --location northeurope

az containerapp env create --name MyContainerappEnvironment --resource-group MicroservicesContainers-rg --location northeurope
az storage account create --name <STORAGE_NAME> --location northeurope --resource-group MicroservicesContainers-rg --sku Standard_LRS

az configure --defaults group=MicroservicesContainers-rg
az configure --defaults location=northeurope

az servicebus namespace create --name Sbnamespace
az servicebus queue create --namespace-name Sbnamespace  --name lower-case
az servicebus queue create --namespace-name Sbnamespace --name upper-case


az functionapp create --resource-group MicroservicesContainers-rg  --name <Appname> --environment MyContainerappEnvironment --storage-account <STORAGE_NAME> --functions-version 4 --runtime dotnet-isolated --image <DOCKER_ID>/<imagename>:v1.0.0  --registry-username <REGISTRY_NAME> --registry-password <ADMIN_PASSWORD>

CONNECTION_STRING= $(az servicebus namespace authorization-rule keys list --namespace-name Sbnamespace  --name RootManageSharedAccessKey --query primaryConnectionString --output tsv)
az functionapp config appsettings set --name <Appname> --resource-group MicroservicesContainers-rg  --settings AzureWebJobsServiceBus=$CONNECTION_STRING

```
At this point you can quickly test if functions is been triggered post publishing messages in the upper-case queue. Send a message to upper-case queue with Service Bus Explorer. For more information, see the [Send a message to a queue or topic section](https://learn.microsoft.com/en-us/azure/service-bus-messaging/explorer#send-a-message-to-a-queue-or-topic) of [Use Service Bus Explorer to run data operations on Service Bus](https://learn.microsoft.com/en-us/azure/service-bus-messaging/explorer). You may check the function logs in the AppInisghts Logs->Traces view 

## Deploy event driven Spring App

```sh
git clone https://github.com/Azure-Samples/ASA-Samples-Event-Driven-Application.git
cd ASA-Samples-Event-Driven-Application
./mvnw clean package -DskipTests


SERVICE_BUS_NAME_SPACE=Sbnamespace 
AZURE_CONTAINER_APPS_ENVIRONMENT=MyContainerappEnvironment
AZURE_SPRING_APPS_INSTANCE=EventDrivenSpringAppsInst
APP_NAME=EventDrivenSpringApp

MANAGED_ENV_RESOURCE_ID=$(az containerapp env show  --name $AZURE_CONTAINER_APPS_ENVIRONMENT  --query id  --output tsv)
az spring create \
    --name ${AZURE_SPRING_APPS_INSTANCE} \
    --managed-environment ${MANAGED_ENV_RESOURCE_ID} \
    --sku standardGen2
    
 
 az spring app create \
    --service ${AZURE_SPRING_APPS_INSTANCE} \
    --name ${APP_NAME} \
    --cpu 1 \
    --memory 2 \
    --min-replicas 2 \
    --max-replicas 2 \
    --runtime-version Java_17 \
    --assign-endpoint true
    
    SERVICE_BUS_CONNECTION_STRING=$(az servicebus namespace authorization-rule keys list \
    --namespace-name ${SERVICE_BUS_NAME_SPACE} \
    --name RootManageSharedAccessKey \
    --query primaryConnectionString \
    --output tsv)
    
    az spring app update \
    --service ${AZURE_SPRING_APPS_INSTANCE} \
    --name ${APP_NAME} \
    --env SERVICE_BUS_CONNECTION_STRING=${SERVICE_BUS_CONNECTION_STRING}
    
    az spring app deploy \
    --service ${AZURE_SPRING_APPS_INSTANCE} \
    --name ${APP_NAME} \
    --artifact-path target/simple-event-driven-app-0.0.1-SNAPSHOT.jar
  ```
  
 ## Microservices working together
    
   Now lets generate load to the service bus queue - lower-case which enables the spring app to convert the messages to upper case and publish them to upper-case queue which will trigger function app to consume the message 
   
```sh
node servicebusscale.js
```
