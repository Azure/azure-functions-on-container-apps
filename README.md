# Azure Functions on Azure Container Apps ![image](https://user-images.githubusercontent.com/45637559/229790891-e36169d8-1cd3-497b-85e2-982874ef6584.png)

> **📢 Important: Native Azure Functions Support Now Available**
> 
> Azure Functions now offers **native integration** with Azure Container Apps (see [announcement](https://techcommunity.microsoft.com/blog/appsonazureblog/announcing-native-azure-functions-support-in-azure-container-apps/4414039)). This is the **recommended hosting method** for most new workloads, combining the full capabilities of Azure Container Apps with the simplicity of the Functions programming model and auto-scaling.
>
> 📚 **Learn more:** [Native Azure Functions Support in Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/functions-overview)  
> 🔧 **Sample template:** [main.bicep](/samples/ACAKindfunctionapp/main.bicep)

## Overview

> **Note:** Always refer to the [official documentation](https://learn.microsoft.com/en-us/azure/container-apps/functions-overview) for the latest information.

Azure Functions on Container Apps enables you to build **event-driven, cloud-native applications** with unprecedented flexibility. Run your functions alongside other microservices, APIs, websites, workflows, or any containerized program—all within a unified platform.

### Why Choose Azure Functions on Container Apps?

- **Leverage the Functions programming model** with your preferred language or framework
- **Zero infrastructure management** - Built on Azure Kubernetes Service with Dapr and KEDA
- **Unified platform** for all your microservices with consistent networking, observability, and scaling
- **Seamless tooling** across Azure Portal, Azure CLI, and CI/CD pipelines (Azure DevOps, GitHub Actions)

## Key Capabilities

### 🚀 Polyglot Application Management
Easily integrate mixed workloads in a single environment:
- Azure Functions
- Azure Container Apps
- Azure Spring Apps
- APIs, websites, and custom containers
- Unified networking, observability, and configuration across all services

### ☁️ Cloud-Native Features
Built-in integration with enterprise-grade technologies:
- **KEDA** for event-driven autoscaling
- **Dapr** for distributed application runtime
- **Envoy** for advanced networking
- Service discovery and native container support

### 🛠️ Developer-Friendly Experience
- Consistent development experience across all Azure Functions hosting options
- Simplified client tooling and DevOps integration
- Inner loop and outer loop development support
- Runtime flexibility with full Functions programming model

### 📊 Dynamic Scaling
- Scale to zero during idle periods
- Scale to dozens of containers under high load
- Event-based scaling with platform-managed triggers

## Common Use Cases

| Scenario | Description |
|----------|-------------|
| **Event Processing** | React to events from HTTP, Kafka, Event Hubs, Service Bus, or Storage Queues and invoke other services |
| **Web Services & APIs** | REST API backends with event-based execution and authentication workflows |
| **Data Ingestion** | Event-based data quality checks for e-commerce, retail, and travel applications with ML workflow integration |
| **Mixed Microservices** | Seamlessly integrate different application types in a single environment |
| **IoT & Edge Computing** | Process events from IoT devices, point-of-sale systems, and edge locations |

## Supported Triggers and Bindings

The following triggers support platform-managed scaling:

✅ **Fully Supported:**
- HTTP
- Timer
- Azure Event Grid
- Azure Event Hubs
- Azure Blob Storage (event-based)
- Azure Queue Storage
- Azure Service Bus
- Kafka
- Durable Functions (MSSQL storage provider)


### Current Limitations

#### Kafka Triggers
- SSL protocol not supported on Container Apps
- For Event Hubs connections, `username` must resolve to an application setting for dynamic scaling

#### Managed Identities
Supported for:
- Azure Container Registry deployments
- Azure Event Hubs, Queue Storage, and Service Bus triggers/bindings
- Required host storage connections

Not yet supported for:
- Durable Functions MSSQL storage provider (coming soon)

#### Other Considerations
- No direct Kubernetes API access
- Cannot move deployments between resource groups or subscriptions
- Azure CLI `containerapp` extension conflicts with `appservice-kube` extension
- Azure Blob Storage and Event Grid don't require Managed Identity configuration

## Regional Availability

Azure Functions on Container Apps is available in all [Container Apps supported regions](https://azure.microsoft.com/en-us/explore/global-infrastructure/products-by-region/?products=container-apps).

### Pricing Plans
- **Consumption plan**: Pay-per-use model
- **Dedicated plan**: Reserved compute capacity
- **Consumption + Dedicated**: Hybrid model ([supported regions](https://learn.microsoft.com/en-us/azure/container-apps/workload-profiles-overview#supported-regions))

Learn more: [Azure Container Apps pricing](https://azure.microsoft.com/pricing/details/container-apps/)

## Azure Functions on Container App V1 vs V2 Hosting options

| Version | Type | Description | Recommendation |
|---------|------|-------------|----------------|
| **V2** | `kind=functionapp` | Native integration with full Container Apps features | ✅ **Recommended for new workloads** |
| **V1** | Legacy | Original hosting model | ⚠️ Supported but not recommended for new projects |

## Getting Started

### 📖 Tutorials
- [Create Azure Functions on Container Apps V2 (kind=functionapp)](./Tutorial%20-%20Create%20Function%20App%20on%20Container%20Apps%20v2.md) - **Recommended**
- [Create Azure Functions on Container Apps V1](./Tutorial%20-%20Create%20Function%20App%20on%20Container%20Apps%20v1.md)

### 🔧 Resources
- [Troubleshooting Guide](./Troubleshooting%20Guide.md)
- [Frequently Asked Questions](./FAQ.md)

## Contributing

This project welcomes contributions and suggestions. Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general). Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party's policies.
