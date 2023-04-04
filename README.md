## Azure Functions on Azure Container Apps (Private Preview) ![image](https://user-images.githubusercontent.com/45637559/229790891-e36169d8-1cd3-497b-85e2-982874ef6584.png)

Azure functions on container apps  helps developers to quickly build event driven, cloud native apps, with the flexibility to run functions along with other microservices, APIs, websites,  workflows or any container hosted programs. You can leverage functions programming model and write code using your preferred programming language or framework that Azure functions supports . You will also get the triggers, bindings and get that first class event driven, cloud native experience. Azure Functions is running on the platform service powered by Azure Container Apps  to run microservices in containers without managing infrastructure. Container Apps Environment is built on a foundation of powerful open-source technology. Behind the scenes, every container app runs on Azure Kubernetes Service, enables to build microservices with full support for Distributed Application Runtime (Dapr) and scale dynamically based on HTTP traffic or events powered by Kubernetes Event-Driven Autoscaling (KEDA). 


Azure Functions on Container Apps Environment offers Azure client tools  and DevOps tooling to provide  seamless experience. This means simplified client tooling features will be enabled with Portal/AzCLI/CICD tools - Azure Pipelines/GitHub Actions. Network and observability configurations  are mapped at Container App Environment so users define these settings at container app environment level which applies to all microservices , functions running as container apps.


## Scenarios
Here are usecases and  scenarios that can be deployed on to Azure Functions on Azure Container Apps

•	React to events from Http/Kafka/Event hubs/Service Bus/Storage Queue and invoke another web or spring based API running in the Container App environment.               Scale on-demand as the events increase

•	Web Services – Rest APIs backend with event based execution requirements or Authentication APIs which trigger during login or authorization events

•	Event based data ingestion platform to perform  data quality checks for online retail/e-commerce/travel apps. This process helps validating  data for data accuracy, data completeness etc. ML workflows get invoked once data quality processing completes

•	Mixed workloads across different app types. Easy integration across other application types like Azure Container Apps and Azure Spring Apps

•	IoT/Point-Of-Sales/Edge event processing microservices applications

## Key Features for Functions on Container App Environment

Functions on Container App environment is designed to meet the needs of cloud-native requirements, while preserving approachability for teams of all sizes and capabilities. It provides unified platform with portability, flexibility, and  developer-centric entry points for building apps

•	Polyglot App Management : The environment enables to easily integrate mixed workloads - polyglot and heterogeneous modern apps or microservices consisting of webapps hosted on Azure Container Apps, Azure Spring apps, APIs, websites or any container hosted programs along side with Functions besides  providing unified networking, observability, dynamic scaling, configuration, and high productivity

•	Enable cloud-native capabilities such as service discovery, native container support, and integration with open source libraries and frameworks like KEDA, Dapr, Envoy

•	Simplified and seamless client and Devops tooling experiences  across Azure Portal, Az CLI, Azure Pipelines, GitHub Actions

•	Dedicated Networking, Observability and pricing plans tied to Container App environment as opposed to a single app types

## Triggers and Bindings that would be available in Private preview 

•	Http 
•	Azure Storage Queue
•	Azure Service Bus
•	Azure EventHub
  Kafka Trigger

## Azure Regions 

•	North Europe
•	East US


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
