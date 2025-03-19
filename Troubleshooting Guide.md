## Troubleshooting Guide


> ##  1) User assigned Managed Identity  is only supported while deploying Azure Functions on Azure Container Apps using Microsoft.App RP and kind=functionapp. 
Note : System assigned Managed Identity  will be enabled in April 2025
While configuring user assigned Managed identity use <CONNECTION_NAME_PREFIX>__managedIdentityResourceId , <CONNECTION_NAME_PREFIX>__clientId support will be added soon by May 2025

> ##  2) Cosmos dB scaling feature with connection string will be enabled in April 2025 and Managed Identity based scaling will estimated to be out by May 2025

> ##  3) Azure Container Apps's Az Portal way of creating and deploying Azure Functions on Azure Container Apps will be released in April 2025. But you can still view the resource overview blades.
Please note do not modify min/max replicas or environment variables from AzPortal or any operation that will result in a new revision creation. As there is a temporary issue that gets created on auto-scaling feature as a result of this.

> ##  4)  Please do not change/update  the WEBSITE_AUTH_ENCRYPTION_KEY 


> ##  5) Post update of functionapp if scaling is not happening correctly, then manually synctrigger the functionapp. 

SyncTrigger can be done manually by either of these methods :   

a) Web Apps - Sync Function Triggers - REST API (Azure App Service) | Microsoft Learn 
b)  Get 'defaultHostName' by doing a call on Sites - Get Site - REST API (Azure Azure Migrate) | Microsoft Learn 
Send an HTTP POST request to https://<defaultHostName>/admin/host/synctriggers?code=<API_KEY> using the master key (Azure Functions HTTP trigger | Microsoft Learn). 
(You can also fetch the master key from StorageAccount>Containers>azure-webjobs-secrets>FunctionappName.) 


>  6) If you already have a appservice-kube extension installed then az functionapp create fails - unrecognized arguments: --environment –image –registry-username –registry-password
 
 In this case you need to uninstall the appservice-kube extension 

> 7) If for new ManagedEnvironment you see a failure for the first time create, please retry. 

> 8) Please do not remove the storage account from the appSettings of functionapp. 

> 9) Use FUNCTIONS_WOKER_RUNTIME="dotnet-isolated" for dotnet isolated based images.  

> 10) Incase you run into latest .net sdk not found issues run below command 

  dotnet add package Microsoft.Azure.Functions.Worker.Sdk --version 1.7.0 

## Below is applicable while deploying Azure Functions using Microsoft.Web resource provider
>1) In case you see below error and trying to access underlying Azure Container Apps resource
_The access is denied because of the deny assignment with name '605xxxxxxxxxxxxxx' and Id '605xxxxxxxx' at scope '/subscriptions/xxxxxxxxxxx/resourceGroups/mrgname '._

## Solution
Users are recommended not to delete/modify the underlying azure container apps resource. As this resource is locked down and will not allow user, group, or service principal to modify/update or deletes. 
This is to protect the function app resource from getting into an inconsistent state.

>10) If you are facing issues with naming convention while using private docker registry. Please follow below guidance
Provide --image with registry.hub.docker.com/<DOCKER ID>/<IMAGE NAME> . For more details refer to this [github discussion](https://github.com/Azure/azure-functions-on-container-apps/issues/66)

az functionapp config container set `
  --name <FUNCTION APP NAME> `
  --resource-group <RESOURCE GROUP> `
  --image registry.hub.docker.com/<DOCKER ID>/<IMAGE NAME> `
  --registry-server registry.hub.docker.com `
  --registry-username <DOCKER ID> `
  --registry-password <PASSWORD>
