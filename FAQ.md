## 1. Which plans are currently supported?
The following plans are currently supported -
- [Azure Container Apps - Pricing | Microsoft Azure - Consumption v1 (GA)](https://azure.microsoft.com/en-in/pricing/details/container-apps/)
- [Azure Container Apps - Pricing | Microsoft Azure - Workload Profile Default Consumption plan](https://azure.microsoft.com/en-in/pricing/details/container-apps/)

  Custom workload profile with dedicated plans are not supported yet. However Support for dedicated plan and workload profile choice will be provided soon. 

## 2. When should I use Azure Functions on Azure Container Apps?
If you have requirements to deploy functions as containers running along side with other microservices in a mixed environment then azure functions on Azure container apps is your option.

## 3. How do I update the image and provision as functions container app?
Yes, you can update the function container app image, if you wish to make changes to your code, modify the image with new version tag and build it, and then finally update the function's container app image please use below command. 

Note: Below sample for docker hub based image or you are already DevOps like Github Actions and Azure Pipeline tasks which will automatically update for you.
```sh

az functionapp config container set --image <ImageName>
                                    --registry-password <Password>
                                     --registry-username <DockerUserId>
                                    --name <MyFunctionApp>
                                    --resource-group <MyResourceGroup>
```

## 4. What container configs can be modified/updated?
The following container configurations can be modified or updated post creation of functions container app 
 
                                   [--image]
                                   [--registry-password]
                                   [--registry-server]
                                   [--registry-username]
                                   [--min-replicas]
                                   [--max-replicas]
      
## 5. Which regions will be supported?
For public preview release the following regions will be supported to deploy Functions on Azure Container Apps
1.	South Central US
2.	UK South
3.	West Europe
4.	East US
5.	Australia East
6.	East Us 2
7.	North Europe
8.	West US3
9.	Central US
    
## 6. How do I configure scale rules for function app?
The managed offering is designed to configure the scale parameters and rules as per the event target. You need not worry about configuring the KEDA scaled objects. Currently below triggers are enabled with platform managed scaling with KEDA
Http
Azure Storage Queue
Azure Service Bus
Azure EventHub
Kafka Trigger
However you will still have the option to set min  replica count using either  az functionapp config container set --name <func_name> [--max-replicas] | [--min-replicas] OR az functionapp create  [--max-replicas] | [--min-replicas] for triggers which are not yet supported

## 7. How does policy effect the access to functions on ACA resource?
From the list of [Azure Policies](https://learn.microsoft.com/en-us/azure/container-apps/policy-reference#policy-definitions) that can be enabled on ACA , only Container app environment policy enforcements will be applicable to functions container app. 
[Container App environments should use network injection - Microsoft Azure](https://ms.portal.azure.com/#view/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2F8b346db6-85af-419b-8557-92cee2c0f9bb) Azure Functions Container App level policy enforcement support will be enabled soon

## 8. Which Azure Functions triggers are supported for Functions on Azure Container Apps?
Below triggers and bindings along with auto scaling are supported for following
•	Http
•	Azure Storage Queue
•	Azure Service Bus
•	Azure EventHub
•	Kafka Trigger(without certs)
However the rest of [Triggers and bindings in Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/functions-triggers-bindings?tabs=csharp#supported-bindings) are supported, but not enabled with auto scaling. You may have to configure ‘x’ number of min replicas to run them

## 9. How can I monitor my Azure Function apps logs?
Application Insights is supported 

## 10. How does the billing happen?
There is no extra cost incurred for running Functions on Azure Container Apps.  It would be same as [Azure Container Apps - Pricing | Microsoft Azure](https://azure.microsoft.com/en-us/pricing/details/container-apps/)

## 11. What client tools are supported to deploy Functions on Azure Container Apps?
Azure Functions on Azure Container Apps deployments are supported using Az CLI, Azure Portal, GitHub Actions, Azure Pipeline Tasks, ARM template deployments , Azure Functions core tools, Bicep templates

## 12. Which version of Function host and extension bundles would be supported?
Extension bundles version compatible with Functions host version v4.17+ will be supported for Azure Functions on Azure Container Apps

## 13. How do I retrieve the url for an http trigger?
This can be achieved using portal or CLI, Under portal go to Functions -> click on function name -> Get Function url or use az functionapp function show command 
az functionapp function show --resource-group AzureFunctionsContainers-rg --name <APP_NAME> --function-name HttpExample --query invokeUrlTemplate
![image](https://github.com/Azure/azure-functions-on-container-apps/assets/45637559/d3f19615-767e-4df0-b140-194507366374)

 

