# Developers guide for Kafka Functions for Python

Explain how to configure and run the sample.

## Prerequisite

If you want to run the sample on Windows, OSX, or Linux, you need to following tools.

* [Azure Function Core Tools](https://github.com/Azure/azure-functions-core-tools) (v3 or above)
* [Python 3.8](https://www.python.org/downloads/release/python-381/)
* [AzureCLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

### Start Virtual Env

```bash
$ python -m venv .venv
$ source .venv/bin/activate
```

### Install Azure Functions Library

```bash
$ pip install -r requirements.txt
```

## Configuration

### EventHubs for Kafka

Add `BrokerList` and `KafkaPassword` to your `local.settings.json`

_local.settings.json_

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "python",
    "BrokerList": "{YOUR_EVENT_HUBS_NAMESPACE}.servicebus.windows.net:9093",
    "KafkaPassword": "{EVENT_HUBS_CONNECTION_STRING}"
  }
}
```

### Others

Modify `function.json` or `KafkaTrigger` attribute according to your broker.
## Run the Azure Functions

## Run 

To test the function locally, run the following command: 

```bash
$ func start
```

### deploy to Azure

#### deploy the app

Deploy the app to a Premium Function You can choose.

* [Quickstart: Create a function in Azure using Visual Studio Code](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-function-vs-code?pivots=programming-language-python)
* [Quickstart: Create a function in Azure that responds to HTTP requests](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-azure-function-azure-cli?tabs=bash%2Cbrowser&pivots=programming-language-python)

#### Configure AppSettings
 You need to configure these application settings. `BrokerList`, `KafkaPassword` to the Function App as required for the sample. Refer to [README](../../README.md)


# Resource

* [Quickstart: Create a function in Azure using Visual Studio Code](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-function-vs-code?pivots=programming-language-python)

