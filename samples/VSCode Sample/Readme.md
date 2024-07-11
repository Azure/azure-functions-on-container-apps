## Deploy Azure Functions on Azure Container Apps using VSCode 

Visual Studio Code is a lightweight but powerful source code editor which runs on your desktop and is available for Windows, macOS and Linux. It comes with built-in support for JavaScript, TypeScript and Node.js and has a rich ecosystem of extensions for other languages and runtimes (such as C++, C#, Java, Python, PHP, Go, .NET). 

## Azure Functions Extension for VSCode

The Azure Functions extension for Visual Studio Code lets you locally develop functions and deploy them to Azure.
The Azure Functions extension provides following  benefits:

Edit, build, and run functions on your local development computer.
Publish your Azure Functions project directly to Azure.
Write your functions in various languages while taking advantage of the benefits of Visual Studio Code.

Lets learn how to create an Azure Function app on Azure Container Apps hosting. This sample covers Python but any Azure Functions supported runtime can be deployed on Azure container Apps hosting using VSCode. 

## Prerequisites
[Visual Studio Code](https://code.visualstudio.com/ ) installed on one of the [supported platforms](https://code.visualstudio.com/docs/supporting/requirements#_platforms).

[Azure Functions extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurefunctions). You can also install the [Azure Tools extension pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode.vscode-node-azure-pack), which is recommended for working with Azure resources.

An active [Azure subscription](https://learn.microsoft.com/en-us/azure/guides/developer/azure-developer-guide#understanding-accounts-subscriptions-and-billing). If you don't yet have an account, you can create one from the extension in Visual Studio Code.

You also need these prerequisites to [run and debug your functions locally](https://learn.microsoft.com/en-us/azure/azure-functions/functions-develop-vs-code?tabs=node-v4%2Cpython-v2%2Cisolated-process&pivots=programming-language-python#run-functions-locally). They aren't required to just create or publish projects to Azure Functions.

The [Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local) , which enables an integrated local debugging experience. When you have the Azure Functions extension installed, the easiest way to install or update Core Tools is by running the Azure Functions: Install or Update Azure Functions Core Tools command from the command palette.
[Python](https://www.python.org/downloads/), one of the [supported versions](https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference-python#python-version).

[Python extension](https://marketplace.visualstudio.com/items?itemName=ms-python.python) for Visual Studio Code.
[Docker extension](https://code.visualstudio.com/docs/containers/overview) for Visual Studio Code

## Creata an Azure Functions Container Project locally

The Functions extension lets you create the required containerized function app project at the same time you create your first function. Use these steps to create an HTTP-triggered function in a new project. An HTTP trigger is the simplest function trigger template to demonstrate

1. In the Activity bar, select the Azure icon. In the Workspace (Local) area, click on Azure Functions icon and select "Create a new Containerized Project"

![image](https://github.com/Azure/azure-functions-on-container-apps/assets/45637559/3d770d6e-1311-4310-8939-18a771550905)

2. Select the directory location for your project workspace, and then choose Select.

3. You can either create a new folder or choose an empty folder for the project workspace, but don't choose a project folder that's already part of a workspace.

4. When prompted, Select a language for your project. If necessary, choose a specific language version. In this case you may choose python and Model V2 (Recommended)

5. Select the HTTP trigger function template, 
![image](https://github.com/Azure/azure-functions-on-container-apps/assets/45637559/c9911956-1419-4364-9099-0b093d563457)

6. For the function name, enter HttpExample, select Enter, and then select Function authorization.

This authorization level requires that you provide a function key when you call the function endpoint.
![image](https://github.com/Azure/azure-functions-on-container-apps/assets/45637559/f12a7e14-98f8-4641-8cab-3b790ab4869d)

7. From the dropdown list, select Add to workspace.
8. 
   ![image](https://github.com/Azure/azure-functions-on-container-apps/assets/45637559/b707181e-a530-4a32-81a5-0602946398a3)

9. In the Do you trust the authors of the files in this folder? window, select Yes.
    
   ![image](https://github.com/Azure/azure-functions-on-container-apps/assets/45637559/65b7bf02-c9ff-44df-ab64-d00279ecdac4)

   Visual Studio Code creates a containerized function in your chosen language and in the template for an HTTP-triggered function.

   ## Generated Project Files
   The project template creates a project in your chosen language and installs the required dependencies. For any language, the new project has these files:

      host.json: Lets you configure the Functions host. These settings apply when you're running functions locally and when you're running them in Azure. For more information, see [host.json reference](https://learn.microsoft.com/en-us/azure/azure-functions/functions-host-json).

      local.settings.json: Maintains settings used when you're locally running functions. These settings are used only when you're running functions locally. For more information, see [Local settings file](https://learn.microsoft.com/en-us/azure/azure-functions/functions-develop-vs-code?tabs=node-v4%2Cpython-v2%2Cisolated-process&pivots=programming-language-python#local-settings)

      Dockerfile: Helps to build Docker image and set environment inside functions container

   ![image](https://github.com/Azure/azure-functions-on-container-apps/assets/45637559/8aaceca5-b235-4938-bced-4642491fe294)

   Depending on your language, these other files are created:

   Files generated depend on the chosen Python programming model for Functions: For v2
   A project-level requirements.txt file that lists packages required by Functions.

   A function_app.py file that contains both the function definition and code.

   At this point, you're able to run your HTTP trigger function locally.

 ## Add a function to your project

   You can add a new function to an existing project based on one of the predefined Functions trigger templates. To add a new function trigger, select F1 to open the command palette, and then find and run the command Azure Functions: Create Function. Follow the prompts to choose your trigger type and define the required attributes of the trigger. If your trigger requires an access key or connection string to connect to a service, get that item ready before you create the function trigger.

This action's results depends on the Python model version.
For V2
Visual Studio Code adds new function code either to the function_app.py file (default behavior) or to another Python file that you selected.

## Connect to services

You can connect your function to other Azure services by adding input and output bindings. Bindings connect your function to other services without you having to write the connection code.

For example, the way you define the output binding that writes data to a storage queue depends on your Python model version.
The way you define the output binding depends on the version of your Python model. For more information, including links to example binding code that you can refer to, see [Add bindings to a function](https://learn.microsoft.com/en-us/azure/azure-functions/add-bindings-existing-function?tabs=python#manually-add-bindings-based-on-examples)

## Create Azure Function on Azure Container Apps resource
Before you can publish your Functions project to Azure, you must have a function app and related resources in your Azure subscription to run your code. The function app provides an execution context for your functions. When you publish from Visual Studio Code to a function app in Azure, the project is packaged and deployed to the selected function app in your Azure subscription.

When you create a function app in Azure, you can choose either a quick function app create path using defaults or an advanced path. This way, you have more control over creating the remote resources.

## Quick function app create
In this section, you create a function app and related resources in your Azure subscription.

Choose the Azure icon in the Activity bar. Then in the Resources area, select the + icon and choose the Create Function App in Azure option.

![image](https://github.com/Azure/azure-functions-on-container-apps/assets/45637559/d01d8e8c-d7d2-4803-b903-82bfbfc8983f)

Provide the following information at the prompts:

1. Select subscription	Choose the subscription to use. You won't see this prompt when you have only one subscription visible under Resources.

Visual Studio Code prompts that Dockerfile is detected and whether code or Container image should be deployed. Since the function has to run as container choose "Container Image"

![image](https://github.com/Azure/azure-functions-on-container-apps/assets/45637559/85885e26-1d94-473b-87e5-8407f1e29611)

2. Enter a globally unique name for the function app	Type a name that is valid in a URL path. The name you type is validated to make sure that it's unique in Azure Functions.
3. Select a location for new resources	For better performance, choose a region near you.

   The extension shows the status of individual resources as they're being created in Azure in the Azure: Activity Log panel.

   ![image](https://github.com/Azure/azure-functions-on-container-apps/assets/45637559/6a142840-4bbd-44c1-84d6-e1376f673ac0)

   When the creation is complete, the following Azure resources are created in your subscription. The resources are named based on your function app name:

- A resource group, which is a logical container for related resources.
-  A standard Azure Storage account, which maintains state and other information about your projects.
-  A Container registry
-  A Container App Environment with workload profile enabled
-  A function app, which provides the environment for executing your function code. A function app lets you group functions as a logical unit for easier management, deployment, and sharing of resources within the same hosting plan.
-  An Application Insights instance connected to the function app, which tracks usage of your functions in the app.

A notification is displayed after your function app is created and the deployment package is applied. You may also check the output console with Azure Functions selected to view the deployement logs

- Note: By default, the Azure resources required by your function app are created based on the function app name you provide. By default, they're also created in the same new resource group with the function app. If you want to either customize the names of these resources or reuse existing resources, you need to publish the project with advanced create options instead.
- 

 ## Publish a project to a new function app in Azure by using advanced options

 The following steps publish your project to a new function app created with advanced create options:

In the command palette, enter Azure Functions: Create function app in Azure...(Advanced).

If you're not signed in, you're prompted to Sign in to Azure. You can also Create a free Azure account. After signing in from the browser, go back to Visual Studio Code.

Visual Studio Code prompts that Dockerfile is detected and whether code or Container image should be deployed. Since the function has to run as container choose "Container Image"

![image](https://github.com/Azure/azure-functions-on-container-apps/assets/45637559/85885e26-1d94-473b-87e5-8407f1e29611)

Following the prompts, provide this information:
- Enter a globally unique name for the new function app.	Type a globally unique name that identifies your new function app and then select Enter. Valid characters for a function app name are a-z, 0-9, and -.
- Select a resource group for new resources.	Choose Create new resource group, and enter a resource group name such as myResourceGroup. You can also select an existing resource group.
- Select a location for new resources.	Select a location in a region near you or near other services that your functions access.
- Select a storage account.	Choose Create new storage account, and at the prompt, enter a globally unique name for the new storage account used by your function app. Storage account names must be between 3 and 24 characters long and can contain only numbers and lowercase letters. You can also select an existing account.
- Select an Application Insights resource for your app.	Choose Create new Application Insights resource, and at the prompt, enter a name for the instance used to store runtime data from your functions.

 A notification appears after your function app is created, and the deployment package is applied. To view the creation and deployment results, including the Azure resources that you created, select View Output in this notification.
You may also check the output console with Azure Functions selected to view the deployement logs

Congratulations!! Proceed to Azure Portal or Get function URL from VScode  to view your Azure Functions on Azure Container apps - http trigger that you just created and copy the url from the http trigger function blade - Get function URL

![image](https://github.com/Azure/azure-functions-on-container-apps/assets/45637559/fd4c0411-8f3d-45da-b48c-b5248941e82b)

 

 Note: At this point Deploy to Azure is not supported

 ## Update code or container image

 If you wish you update code then perform below steps:
 
 1. Rebuild your image post making changes to the code by following below steps. For detailed steps see [here](https://github.com/Azure/azure-functions-on-container-apps?tab=readme-ov-file#build-the-container-image-and-test-locally)
    
    ```sh
    acr login --name <acrname>
    docker build -t <imagename>:<tagname>
    ``
 
 2. Push the image with an updated version tag to the container registry that VSCode created

      ```sh
      docker tag <imagename>:<tagname> <acrname>.azurecr.io/<imagename>:<tagname>
    az acr build --registry <acrname> --image <acrname>.azurecr.io/<imagename>:<tagname> .
    or
    docker push <acrname>.azurecr.io/<imagename>:<tagname>
   ``
   

 3. Update the configuration of the Azure Functions on ACA resource
    
       i\.    Using AzCLI follow the instructions [here](https://github.com/Azure/azure-functions-on-container-apps/blob/main/README.md#update-function-container-image)
    
       ii\.  Using Azure Portal Goto Functions Overview > Configuration > Update the Image tag from the drop down as shown below

    ![image](https://github.com/Azure/azure-functions-on-container-apps/assets/45637559/fb5d5e09-534c-40fa-8ef5-5abdec93d8f7)

    

       iii\. Inacase you wish to redeploy the app with updated image details then modify the image name in your Deployment pipelines/ARM/Bicep templates and re-deploy them

    







   
  


