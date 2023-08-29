# Azure Developer CLI (azd) Azure Functions on Azure Container Apps Starter

A starter blueprint for getting your application up on Azure using [Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/overview) (azd). Add your application code, write Infrastructure as Code assets in [Bicep](https://aka.ms/bicep) to get your application up and running quickly.

The following assets have been provided:

- Infrastructure-as-code (IaC) Bicep files under the `infra` folder that demonstrate how to provision resources and setup resource tagging for azd.


## Next Steps
1. Clone the repo or use code spaces
2. Go to folder consisting of azd code
3. Go to infra/main.parameters.json and replace the apiImageName with your image url of your container registry
2. In the terminal execute and provide inputs such as subscription, Azure region to deploy the Azure resources

   ```sh
   Run azd env new (provide a new environment name)
   Then run azd up
   ```
- Run `azd up` to validate both infrastructure and application code changes.
- Run `azd deploy` to validate application code changes only.

  Optionally you may visit Azure portal and navigate to the Deployment under the Resource Group created to monitor the deployment progress and Azure resources that are created
  

