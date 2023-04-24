## Troubleshooting Guide

> 1) Post update of functionapp if scaling is not happening correctly, then manually synctrigger the functionapp. 
SyncTrigger can be done manually by either of these methods :   

a) Web Apps - Sync Function Triggers - REST API (Azure App Service) | Microsoft Learn 
b)  Get 'defaultHostName' by doing a call on Sites - Get Site - REST API (Azure Azure Migrate) | Microsoft Learn 
Send an HTTP POST request to https://<defaultHostName>/admin/host/synctriggers?code=<API_KEY> using the master key (Azure Functions HTTP trigger | Microsoft Learn). 
(You can also fetch the master key from StorageAccount>Containers>azure-webjobs-secrets>FunctionappName.) 

>  2) Please do not change the WEBSITE_AUTH_ENCRYPTION_KEY
>  3) If you already have a appservice-kube extension installed then az functionapp create fails - unrecognized arguments: --environment –image –registry-username –registry-password
 
 In this case you need to uninstall the appservice-kube extension 

> 4) If for new ManagedEnvironment you see a failure for the first time create, please retry. 

> 5) Please do not remove the storage account from the appSettings of functionapp. 

> 6) Use FUNCTIONS_WOKER_RUNTIME="dotnet-isolated" for dotnet isolated based images.  

> 7) Incase you run into latest .net sdk not found issues run below command 

  dotnet add package Microsoft.Azure.Functions.Worker.Sdk --version 1.7.0 

> 8) Incase you see below error:

{ 

  "Code": "BadRequest", 

  "Message": "Requested features are not allowed for subscription.", 

} 
That means your subscription whitelisting has expired, please reach out to get your subscription whitelisted. 
