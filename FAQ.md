# Frequently Asked Questions - Azure Functions on Azure Container Apps (v1)

> [!IMPORTANT]
> If you're creating a new function app for the first time, we recommend using the [Azure Functions on Azure Container Apps v2 (kind=functionapp)](./azure-functions-on-container-apps-v2.md) hosting option instead of this v1 approach.


## 1. Which plans are currently supported?

Azure Functions on Container Apps currently supports the following pricing plans:

- **[Consumption v1 (GA)](https://azure.microsoft.com/en-in/pricing/details/container-apps/)** - Pay-per-use model
- **[Workload Profile Default Consumption](https://azure.microsoft.com/en-in/pricing/details/container-apps/)** - Standard consumption tier

**Note:** Custom workload profiles with dedicated plans are not yet supported but will be available soon.

## 2. When should I use Azure Functions on Azure Container Apps?

Choose Azure Functions on Container Apps when you need to:
- Deploy functions as containers alongside other microservices
- Run functions in a mixed microservices environment
- Leverage container-based deployment strategies for your serverless workloads

## 3. How do I update the container image for my Functions app?

To update your Functions container app with a new image:

1. Modify your code and build a new image with an updated version tag
2. Update the Functions container app using the following command:

```sh
az functionapp config container set --image <ImageName>
                  --registry-password <Password>
                  --registry-username <DockerUserId>
                  --name <MyFunctionApp>
                  --resource-group <MyResourceGroup>
```

**Note:** You can also automate this process using CI/CD tools like GitHub Actions or Azure Pipeline tasks.

## 4. What container configurations can be modified post-creation?

The following configurations can be updated after creating your Functions container app:

- `--image` - Container image
- `--registry-password` - Registry authentication password
- `--registry-server` - Container registry server URL
- `--registry-username` - Registry authentication username
- `--min-replicas` - Minimum number of replicas
- `--max-replicas` - Maximum number of replicas

## 5. Which regions are supported?

During public preview, Azure Functions on Container Apps is available in:

1. South Central US
2. UK South
3. West Europe
4. East US
5. Australia East
6. East US 2
7. North Europe
8. West US 3
9. Central US

## 6. How do I configure scaling rules?

### Automatic Scaling
The platform automatically configures KEDA-based scaling for these triggers:
- HTTP
- Azure Storage Queue
- Azure Service Bus
- Azure EventHub
- Kafka Trigger

### Manual Configuration
For unsupported triggers, configure replica counts manually:

**During creation:**
```sh
az functionapp create [--max-replicas <value>] [--min-replicas <value>]
```

**After creation:**
```sh
az functionapp config container set --name <func_name> [--max-replicas <value>] [--min-replicas <value>]
```

## 7. How do Azure Policies affect Functions on Container Apps?

Currently, only [Container App environment policies](https://learn.microsoft.com/en-us/azure/container-apps/policy-reference#policy-definitions) apply to Functions container apps, such as:
- [Container App environments should use network injection](https://ms.portal.azure.com/#view/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2F8b346db6-85af-419b-8557-92cee2c0f9bb)

**Note:** Container App-level policy enforcement for Azure Functions will be available soon.

## 8. Which triggers and bindings are supported?

### Fully Supported (with auto-scaling):
- HTTP
- Azure Storage Queue
- Azure Service Bus
- Azure EventHub
- Kafka Trigger (without certificates)

### Partially Supported (without auto-scaling):
All other [Azure Functions triggers and bindings](https://learn.microsoft.com/en-us/azure/azure-functions/functions-triggers-bindings?tabs=csharp#supported-bindings) work but require manual configuration of minimum replicas.

## 9. How can I monitor my Functions app?

Application Insights is fully supported for monitoring and logging your Azure Functions on Container Apps.

## 10. How is billing calculated?

Azure Functions on Container Apps follows the standard [Azure Container Apps pricing](https://azure.microsoft.com/en-us/pricing/details/container-apps/) model with no additional charges for Functions.

## 11. Which deployment tools are supported?

Deploy Functions on Container Apps using:
- Azure CLI
- Azure Portal
- GitHub Actions
- Azure Pipeline Tasks
- ARM Templates
- Azure Functions Core Tools
- Bicep Templates

## 12. What are the version requirements?

- **Functions Host:** Version 4.17 or later
- **Extension Bundles:** Versions compatible with Functions host v4.17+

## 13. How do I retrieve HTTP trigger URLs?

### Using Azure Portal:
1. Navigate to your Functions app
2. Click on the function name
3. Select "Get Function URL"

![Get Function URL](https://github.com/Azure/azure-functions-on-container-apps/assets/45637559/d3f19615-767e-4df0-b140-194507366374)

### Using Azure CLI:
```sh
az functionapp function show --resource-group AzureFunctionsContainers-rg \
              --name <APP_NAME> \
              --function-name HttpExample \
              --query invokeUrlTemplate
```
