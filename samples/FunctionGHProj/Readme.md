Use [GitHub Actions](https://github.com/features/actions) to define a workflow to automatically build and deploy code to your function app in Azure Functions.

In GitHub Actions, a [workflow](https://docs.github.com/en/actions/learn-github-actions/introduction-to-github-actions#the-components-of-github-actions) is an automated process that you define in your GitHub repository. This process tells GitHub how to build and deploy your function app project on GitHub.

A workflow is defined by a YAML (.yml) file in the /.github/workflows/ path in your repository. This definition contains the various steps and parameters that make up the workflow.

For an Azure Functions workflow, the file has three sections:

