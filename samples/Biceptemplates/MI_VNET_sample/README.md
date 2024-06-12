# Functions on ACA - MI, VNET sample

## Overview

This is a sample project to get started with MI integration for Functions on ACA, and optionally enable VNet on the managed environment.

For MI integration, it creates:
- A keyvault, ACR, storage account and User assigned identity with necessary permissions on these resources
- Assigns this identity to the function app.
- Sets the right app settings and configuration on the function app to:
  - Use keyvault references
  - Pull images from private ACR
  - Access storage account without connection strings.
- Set `useSystemIdentity` = `true`, in order to use system assigned identity instead of user managed identity in above steps.

For VNet integration, it provides two flags in params:
- hasVnet: To create and add a VNet to the managed environment.
- isVnetInternal: To enable only internal Vnet traffic.
By default, these flags are set to false.

## Resource creation

- One of the ways to deploy these bicep templates is by opening them in vscode and [using bicep extension to deploy them](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/visual-studio-code?tabs=CLI#deploy-bicep-file).
- After installing the bicep extension, right click on the `index.bicep` and choose `Deploy Bicep File...`

Note: Each time this template is deployed, new resources get created with random strings. To consistently create or update the same set of resources, please set `prefix` parameter in `index.bicepparam` file to some unique string.

## Updating the image

- This project creates the function app using default sample image: `mcr.microsoft.com/azure-functions/dotnet8-quickstart-demo:1.0`
- To use a private image, push your image to the ACR created above and update the function app config to use the private image. Function app would then pull the image in private acr using MI.

### Sample steps

1. Import your image to the private ACR created above:
   ```
   az acr import \
     --name <acr name> \
     --source mcr.microsoft.com/azure-functions/dotnet8-quickstart-demo:1.0 \
     --image azure-functions/dotnet8-quickstart-demo:1.0
   ```
   Verify the image is imported correctly.

2. Update the image config on the function app to use private image: <br/>
   In the below command, update the linuxFxVersion by replacing function app name, resource group name and acr name appropriately.
   ```
   az resource update \
      -g <resource group name> \
      -n <function app name>/config/web \
      --subscription <subscription name> \
      --resource-type 'Microsoft.Web/sites/config' \
      --set properties.linuxFxVersion="DOCKER|<acr name>.azurecr.io/azure-functions/dotnet8-quickstart-demo:1.0"
   ```
   Verify the linuxFxVersion is updated correctly, in JSON View in Portal. 
