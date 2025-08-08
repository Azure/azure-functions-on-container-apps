## Azure Functions on Azure Container Apps ![image](https://user-images.githubusercontent.com/45637559/229790891-e36169d8-1cd3-497b-85e2-982874ef6584.png)

> **Important Note** 
> A new hosting method for running Azure Functions natively in Azure Container Apps is now available (see [announcement](https://techcommunity.microsoft.com/blog/appsonazureblog/announcing-native-azure-functions-support-in-azure-container-apps/4414039)) and recommended for most new workloads. This integration allows you to leverage the full features and capabilities of Azure Container Apps while benefiting from the functions programming model and simplicity of auto-scaling provided by Azure Functions.
>
> For more information, see [Native Azure Functions Support in Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/functions-overview). Sample bicep template - [main.bicep](/samples/ACAKindfunctionapp/main.bicep)

Azure functions on container apps  helps developers to quickly build event driven, cloud native apps, with the flexibility to run functions along with other microservices, APIs, websites,  workflows or any container hosted programs. You can leverage functions programming model and write code using your preferred programming language or framework that Azure functions supports . You will also get the triggers, bindings and get that first class event driven, cloud native experience. Azure Functions is running on the platform service powered by Azure Container Apps  to run microservices in containers without managing infrastructure. Container Apps Environment is built on a foundation of powerful open-source technology. Behind the scenes, every container app runs on Azure Kubernetes Service, enables to build microservices with full support for Distributed Application Runtime (Dapr) and scale dynamically based on HTTP traffic or events powered by Kubernetes Event-Driven Autoscaling (KEDA). 

Azure Functions on Container Apps Environment offers Azure client tools  and DevOps tooling to provide  seamless experience. This means simplified client tooling features will be enabled with Portal/AzCLI/CICD tools - Azure Pipelines/GitHub Actions. Network and observability configurations  are mapped at Container App Environment so users define these settings at container app environment level which applies to all microservices , functions running as container apps.
-  **Polyglot App Management** : The environment enables to easily integrate mixed workloads - polyglot and heterogeneous modern apps or microservices consisting of webapps hosted on Azure Container Apps, Azure Spring apps, APIs, websites or any container hosted programs along side with Functions besides  providing unified networking, observability, dynamic scaling, configuration, and high productivity
-  **Enable cloud-native capabilities** such as service discovery, native container support, and integration with open source libraries and frameworks like KEDA, Dapr, Envoy
-  **Simplified and seamless client and Devops tooling experiences**  across Azure Portal, Az CLI, Azure Pipelines, GitHub Actions
-  **Dedicated Networking, Observability and pricing plans** tied to Container App environment as opposed to a single app types


## Scenarios
Here are use cases and  scenarios that can be deployed on to Azure Functions on Azure Container Apps

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

## Triggers and Bindings that would have platform managed scaling enabled so far

> Always refer [Public documentation](https://learn.microsoft.com/en-us/azure/container-apps/functions-overview) for latest information 

- Azure Event Grid
- Azure Event Hubs
- Azure Blob storage (event-based)
- Azure Queue Storage
- Azure Service Bus
- Durable Functions (MSSQL storage provider)
- HTTP
- Kafka
- Timer

These limitations apply to Kafka triggers:
- The protocol value of ssl isn't supported when hosted on Container Apps. Use a different protocol value.
For a Kafka trigger to dynamically scale when connected to Event Hubs, the username property must resolve to an application setting that contains the actual username value. When the default $ConnectionString value is used, the Kafka trigger won't be able to cause the app to scale dynamically.
For the built-in Container Apps policy definitions, currently only environment-level policies apply to Azure Functions containers.
- You can use managed identities for these connections:
  - Deployment from an Azure Container Registry
  -  Triggers and bindings such as Azure Event Hubs, Azure Queue Storage, Azure Service Bus only
  - Required host storage connection
- Durable Functions (MSSQL storage provider) will scale from and to zero and beyond with connection string only. MI is not yet supported. This is coming soon.
- You currently can't move a Container Apps hosted function app deployment between resource groups or between subscriptions. Instead, you would have to recreate the existing containerized app deployment in a new resource group, subscription, or region.
- When using Container Apps, you don't have direct access to the lower-level Kubernetes APIs.
- The containerapp extension conflicts with the appservice-kube extension in Azure CLI. If you have previously published apps to Azure Arc, run az extension list and make sure that appservice-kube isn't installed. If it is, you can remove it by running az extension remove -n appservice-kube.
## Note 
 Azure Blob Storage(event based), Azure Event Grid do not need Managed Identity connections configured to these Azure services

## Azure Regions 

Container Apps support for Functions  is  available on all Azure Container Apps supported regions. See the list of supported regions [here](https://azure.microsoft.com/en-us/explore/global-infrastructure/products-by-region/?products=container-apps)


When your container is hosted in a [Consumption + Dedicated plan](https://learn.microsoft.com/en-us/azure/container-apps/plans#consumption-dedicated) structure, both Consumption and Dedicated plan are currently supported. For more information on Container apps pricing, see the [Azure Container Apps pricing page](https://azure.microsoft.com/pricing/details/container-apps/). For list of supported regions in this plan [see here](https://learn.microsoft.com/en-us/azure/container-apps/workload-profiles-overview#supported-regions)

## Difference between V1 and V2 function hosting
<TODO>

## Create the function app
- [Create an Azure function on Container Apps v2 (kind=functionapp)](./Tutorial%20-%20Create%20Function%20App%20on%20Container%20Apps%20v2.md) - **Recommended** for new setup
- [Create an Azure function on Container Apps v1](./Tutorial%20-%20Create%20Function%20App%20on%20Container%20Apps%20v1.md)

## TroubleShooting 
Having issues with creating Azure Functions on Azure Container apps please refer to the [troubleshooting guide](https://github.com/Azure/azure-functions-on-container-apps/blob/main/Troubleshooting%20Guide.md)

## FAQ
Refer to the FAQ to know more about the offering - [FAQ](https://github.com/Azure/azure-functions-on-container-apps/blob/main/FAQ.md)

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
