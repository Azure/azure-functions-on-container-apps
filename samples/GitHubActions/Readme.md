# Deploy container to Azure Functions App
This workflow will build a container and deploy it to an Azure Functions App on Linux when a commit is pushed to your default branch.

## Pre-requisite
This workflow assumes you have already created the target Azure Functions app.

## To configure this workflow:
1. Set up the following secrets in your repository:
   - AZURE_RBAC_CREDENTIALS
   - REGISTRY_USERNAME
   - REGISTRY_PASSWORD
2. Change env variables for your configuration.
3. Add this yaml file to your project's .github/workflows/
4. Push your local project to your GitHub Repository

## For more information on:
   - GitHub Actions for Azure: https://github.com/Azure/Actions
   - Azure Functions Container Action: https://github.com/Azure/functions-container-action
   - Azure Service Principal for RBAC: https://github.com/Azure/functions-action#using-azure-service-principal-for-rbac-as-deployment-credential

## For more information on GitHub Actions:
https://help.github.com/en/categories/automating-your-workflow-with-github-actions
