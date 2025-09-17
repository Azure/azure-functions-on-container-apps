## Overview
> **📢 Important: Native Azure Functions Support Now Available**
> 
> Azure Functions now offers **native integration** with Azure Container Apps (see [announcement](https://techcommunity.microsoft.com/blog/appsonazureblog/announcing-native-azure-functions-support-in-azure-container-apps/4414039)). This is the **recommended hosting method** for most new workloads, combining the full capabilities of Azure Container Apps with the simplicity of the Functions programming model and auto-scaling.
>

> **Note:** Always refer to the [official documentation](https://learn.microsoft.com/en-us/azure/azure-functions/functions-container-apps-hosting) for the latest information.

### Managed Resource Groups

Azure Functions on Container Apps uses **managed resource groups** to run your containerized function app resources. These specially managed groups:

- **Auto-created**: Generated automatically when you first create function app resources in a Container Apps environment
- **Shared**: Reused by all function apps in the same environment
- **Protected**: Prevent unauthorized modification or deletion of resources, even by service principals
- **Auto-removed**: Deleted automatically when all function app container resources are removed from the environment

**Important**: 
- Managed resource groups are visible but cannot be directly modified or deleted
- Any modification attempts will result in an error
- To remove a managed resource group, remove all function app container resources from the environment
- For issues with managed resource groups, contact support

## Getting Started

### Tutorials
- [Create Azure Functions on Container Apps V1](./Tutorial%20-%20Create%20Function%20App%20on%20Container%20Apps%20v1.md) 
- Refer official [documentation tutorial](https://learn.microsoft.com/en-us/azure/azure-functions/functions-deploy-container-apps)

### Samples
- [Sample bicep template](../samples/Biceptemplates/Func_on_ACA_Bicepdeploy.bicep)

### Resources
- [Troubleshooting Guide](./Troubleshooting%20Guide.md)
- [Frequently Asked Questions](./FAQ.md)

# Feedback
If you encounter issues, [open an issue on GitHub](https://github.com/Azure/azure-functions-on-container-apps/issues).

