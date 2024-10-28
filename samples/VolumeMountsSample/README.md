# Functions on ACA - Volume mounts sample

## Overview

This is a sample project to get started with Volume mounts on Functions on ACA.
It creates a storage account with file share. Configures the storage on ACA environment resource, and then sets up storage mount on the Function on ACA resource using the ACA env storage details.

Setting use_nfs_mount = true in the parameters will create a vnet and a premium storage with nfs based file share with related setup and use it in the ACA env.

## How to configure storage mounts for Fn on ACA

Storage mount creation and connection setup is done at Environment level similar to regular ACA apps as documented at [how to set up storage mounts in Container App Environment](https://learn.microsoft.com/en-us/azure/container-apps/storage-mounts?tabs=smb&pivots=azure-resource-manager).

To bring in the configured storage mounts as "volumes" for Fn on ACA, we can use the currently available storage account configuration API under websites , with few variations wrt the properties in [AzureStorageInfoValue](https://learn.microsoft.com/en-us/rest/api/appservice/web-apps/create-or-update-configuration?view=rest-appservice-2023-12-01&tabs=HTTP#azurestorageinfovalue): 

- `accessKey`: Not applicable for Functions on ACA as connection setup is done at environment level. Can be skipped or set as empty.
- `accountName`: Should be the name of storage resource configured under Container Apps Environment.  
Note: If this is set as empty, it will be considered an [`EmptyDir` (Replica scoped storage type)](https://learn.microsoft.com/en-us/azure/container-apps/storage-mounts?tabs=smb&pivots=azure-resource-manager#replica-scoped-storage)
- `mountPath` - Path within the container at which the volume should be mounted.
- `protocol` – Nfs or Smb. (Http is not supported).
Note: This is ignored when accountName is empty, as protocol is not applicable for EmptyDir storage type.
- `shareName` – This can be used to provide [`subpath`](https://learn.microsoft.com/en-us/rest/api/containerapps/container-apps/get?view=rest-containerapps-2024-03-01&tabs=HTTP#volumemount) which is the path within the volume from which the container's volume should be mounted. Defaults to ""
- `state` – This is not supported and always set to OK
- `type` – Only `AzureFiles` is supported for Fn on ACA.

## Resource creation

- One of the ways to deploy these bicep templates is by opening them in vscode and [using bicep extension to deploy them](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/visual-studio-code?tabs=CLI#deploy-bicep-file).
- After installing the bicep extension, right click on the `index.bicep` and choose `Deploy Bicep File...`
- Note: You can change the dep_name to generate new set of resources everytime.

## Updating the image

- This infra deploys the function app using default sample image: `mcr.microsoft.com/azure-functions/dotnet8-quickstart-demo:1.0`
- Sample python function code which reads and writes to the mount path is provided under `code` folder as reference.
- Build your image for your fn app and push it to an ACR, and then use Portal's Configuration blade to pick an image from your ACR.