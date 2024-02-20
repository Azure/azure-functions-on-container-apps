# TimerTrigger Project

This project contains an Azure Functions application that uses a TimerTrigger.

## Overview

The TimerTrigger makes it incredibly straightforward to execute a function on a schedule. This project demonstrates how to set up a function that runs at a set interval, using CRON expression for scheduling.

## Getting Started

### Prerequisites

- An Azure account with an active subscription.
- Azure Functions Core Tools
- .NET 8.0 | .NET 7.01 | .NET 6.02 | .NET Framework 4.83
- Azure CLI

### Local Development

Clone the repository and navigate to the TimerTrigger project folder.

```bash
git clone <repository-url>
cd TimerTrigger
```
---

Follow the steps from [here](https://github.com/Azure/azure-functions-on-container-apps/blob/main/README.md#build-the-container-image-and-test-locally) to build, test and push
the Timertrigger image to the container registry of your choice. Post the execution of func start or docker run monitor the function logs to ensure the jobs executed successfully in the
scheduled time.

### Deploy to Azure

Follow the steps [here](https://github.com/Azure/azure-functions-on-container-apps/blob/main/README.md#create-azure-resources) to deploy the image as functions container and monitor
the Live Metrics and Traces tables in AppInsights to ensure the job executed successfully in the scheduled time.

### Contributing
Please read CONTRIBUTING.md for details on our code of conduct, and the process for submitting pull requests.

### License
This project is licensed under the MIT License - see the LICENSE.md file for details.
