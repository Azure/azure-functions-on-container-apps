# Functions on ACA - Volume mounts sample

## Overview

This is a sample project to get started with Volume mounts on Functions on ACA.
It creates a storage account with file share. Configures the storage on ACA environment resource, and then sets up storage mount on the Function on ACA resource using the ACA env storage details.

- Reference: [how to set up storage mounts in Container App Environment](https://learn.microsoft.com/en-us/azure/container-apps/storage-mounts?tabs=smb&pivots=azure-resource-manager)

## Resource creation

- One of the ways to deploy these bicep templates is by opening them in vscode and [using bicep extension to deploy them](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/visual-studio-code?tabs=CLI#deploy-bicep-file).
- After installing the bicep extension, right click on the `index.bicep` and choose `Deploy Bicep File...`
- Note: You can change the dep_name to generate new set of resources everytime.

## Updating the image

- This infra deploys the function app using default sample image: `mcr.microsoft.com/azure-functions/dotnet8-quickstart-demo:1.0`
- Sample python function code which reads and writes to the mount path is provided under `code` folder as reference.
- Build your image for your fn app and push it to an ACR, and then use Portal's Configuration blade to pick an image from your ACR.