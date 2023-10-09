# Azure Developer CLI (azd) Deployment steps

A starter blueprint for getting your application up on Azure using [Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/overview) (azd). Add your application code, write Infrastructure as Code assets in [Bicep](https://aka.ms/bicep) to get your application up and running quickly.

The following assets have been provided:

- Infrastructure-as-code (IaC) Bicep files under the `infra` folder that demonstrate how to provision resources and setup resource tagging for azd.
- A [dev container](https://containers.dev) configuration file under the `.devcontainer` directory that installs infrastructure tooling by default. This can be readily used to create cloud-hosted developer environments such as [GitHub Codespaces](https://aka.ms/codespaces).
- Continuous deployment workflows for CI providers such as GitHub Actions under the `.github` directory, and Azure Pipelines under the `.azdo` directory that work for most use-cases.

## Next Steps

## Next Steps
1. Clone the repo or use code spaces
2. Go to folder consisting of azd code
3. Go to infra/main.parameters.json and replace the apiImageNameCO and apiImageNameHP values  with the respective image url of your container registry. Under CodeSample/ folder in this repo you may find the python Http Function app - CodeSample/HttpFrontEnd  and Create Order function app CodeSample/CreateOrder  code that you may containerize and upload to the container registry
4. In the terminal execute and provide inputs such as subscription, Azure region to deploy the Azure resources

   ```sh
   Run azd env new (provide a new environment name)
   Then run azd up
   ```
- Run `azd up` to validate both infrastructure and application code changes.
- Run `azd deploy` to validate application code changes only.

  Optionally you may visit Azure portal and navigate to the Deployment under the Resource Group created to monitor the deployment progress and Azure resources that are created
