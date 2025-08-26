# Troubleshooting Guide

## Known Issues and Limitations

### 1. Managed Identity Support
- **User Assigned Managed Identity**: Currently supported when deploying Azure Functions on Azure Container Apps using `Microsoft.App` RP with `kind=functionapp`
  - When configuring, use: `<CONNECTION_NAME_PREFIX>__managedIdentityResourceId`
  - `<CONNECTION_NAME_PREFIX>__clientId` support coming May 2025
- **System Assigned Managed Identity**: Available April 2025

### 2. Cosmos DB Scaling
- **Connection String-based Scaling**: Available April 2025
- **Managed Identity-based Scaling**: Estimated May 2025

### 3. Azure Portal Deployment
- **Portal Deployment**: Full support coming April 2025
- **Current Capabilities**: Resource overview blades are available
- **⚠️ Important**: Do NOT modify the following from Azure Portal:
  - Min/Max replicas
  - Environment variables
  - Any operation creating a new revision
  
  *These modifications cause temporary auto-scaling issues*

### 4. Security Configuration
**Do NOT change or update** the `WEBSITE_AUTH_ENCRYPTION_KEY` setting

### 5. Scaling Issues After Updates
If scaling doesn't work correctly after updating a function app, manually trigger synchronization:

**Method A**: Use REST API
- [Web Apps - Sync Function Triggers](https://docs.microsoft.com/rest/api/appservice/webapps/syncfunctiontriggers)

**Method B**: Direct HTTP Request
1. Get `defaultHostName` via [Sites - Get Site REST API](https://docs.microsoft.com/rest/api/appservice/sites/get)
2. Send POST request to: `https://<defaultHostName>/admin/host/synctriggers?code=<API_KEY>`
3. Use the master key (found in: StorageAccount > Containers > azure-webjobs-secrets > FunctionappName)

### 6. Extension Conflicts
**Issue**: `az functionapp create` fails with error: `unrecognized arguments: --environment –image –registry-username –registry-password`

**Solution**: Uninstall the `appservice-kube` extension if already installed

### 7. ManagedEnvironment Creation
If first-time creation fails for new ManagedEnvironment, retry the operation

### 8. Storage Account Requirement
**Do NOT remove** the storage account from the function app's appSettings

### 9. .NET Isolated Runtime
Use `FUNCTIONS_WORKER_RUNTIME="dotnet-isolated"` for .NET isolated-based images

### 10. .NET SDK Issues
If encountering "latest .NET SDK not found" errors, run:
```bash
dotnet add package Microsoft.Azure.Functions.Worker.Sdk --version 1.7.0
```

## Microsoft.Web Resource Provider Specific Issues

### Access Denied Error
**Error Message**: 
```
The access is denied because of the deny assignment with name '605xxxxxxxxxxxxxx' and Id '605xxxxxxxx' at scope '/subscriptions/xxxxxxxxxxx/resourceGroups/mrgname'
```

**Solution**: Do not attempt to delete or modify the underlying Azure Container Apps resource. This resource is locked to prevent users, groups, or service principals from making changes that could cause the function app to enter an inconsistent state.

## Docker Registry Configuration

### Private Docker Registry Naming Convention
When using private Docker registries, follow this format:

**Command Example**:
```bash
az functionapp config container set \
  --name <FUNCTION APP NAME> \
  --resource-group <RESOURCE GROUP> \
  --image registry.hub.docker.com/<DOCKER ID>/<IMAGE NAME> \
  --registry-server registry.hub.docker.com \
  --registry-username <DOCKER ID> \
  --registry-password <PASSWORD>
```

**Note**: Always use the full registry URL format: `registry.hub.docker.com/<DOCKER ID>/<IMAGE NAME>`

For more details, see this [GitHub discussion](https://github.com/Azure/azure-functions-on-container-apps/issues/66)
