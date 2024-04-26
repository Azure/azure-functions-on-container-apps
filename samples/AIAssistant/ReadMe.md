# Azure Functions bindings for OpenAI's GPT engine

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build](https://dev.azure.com/azfunc/Azure%20Functions/_apis/build/status%2FExtension-OpenAI%2FAzure%20Functions%20OpenAI%20Extension%20PR%20CI?branchName=main)](https://dev.azure.com/azfunc/Azure%20Functions/_build/latest?definitionId=303&branchName=main)

This project adds support for [OpenAI](https://platform.openai.com/) LLM (GPT-3.5-turbo, GPT-4) bindings in [Azure Functions](https://azure.microsoft.com/products/functions/).

This extension depends on the [Azure AI OpenAI SDK](https://github.com/Azure/azure-sdk-for-net/tree/main/sdk/openai/Azure.AI.OpenAI).

## NuGet Packages

The following NuGet packages are available as part of this project.

[![NuGet](https://img.shields.io/nuget/v/Microsoft.Azure.Functions.Worker.Extensions.OpenAI.svg?label=microsoft.azure.functions.worker.extensions.openai)](https://www.nuget.org/packages/Microsoft.Azure.Functions.Worker.Extensions.OpenAI)
[![NuGet](https://img.shields.io/nuget/v/Microsoft.Azure.Functions.Worker.Extensions.OpenAI.Kusto.svg?label=microsoft.azure.functions.worker.extensions.openai.kusto)](https://www.nuget.org/packages/Microsoft.Azure.Functions.Worker.Extensions.OpenAI.Kusto)
[![NuGet](https://img.shields.io/nuget/v/Microsoft.Azure.Functions.Worker.Extensions.OpenAI.AzureAISearch.svg?label=microsoft.azure.functions.worker.extensions.openai.azureaisearch)](https://www.nuget.org/packages/Microsoft.Azure.Functions.Worker.Extensions.OpenAI.AzureAISearch)
[![NuGet](https://img.shields.io/nuget/v/Microsoft.Azure.Functions.Worker.Extensions.OpenAI.CosmosDBSearch.svg?label=microsoft.azure.functions.worker.extensions.openai.cosmosdbsearch)](https://www.nuget.org/packages/Microsoft.Azure.Functions.Worker.Extensions.OpenAI.CosmosDBSearch)

## Requirements

* [.NET 6 SDK](https://dotnet.microsoft.com/download/dotnet/6.0) or greater (Visual Studio 2022 recommended)
* [Azure Functions Core Tools v4.x](https://learn.microsoft.com/azure/azure-functions/functions-run-local?tabs=v4%2Cwindows%2Cnode%2Cportal%2Cbash)
* Update settings in Azure Function or the `local.settings.json` file for local development with the following keys:
    1. For Azure, `AZURE_OPENAI_ENDPOINT` - [Azure OpenAI resource](https://learn.microsoft.com/azure/ai-services/openai/how-to/create-resource?pivots=web-portal) (e.g. `https://***.openai.azure.com/`) set.
    1. For Azure, assign the user or function app managed identity `Cognitive Services OpenAI User` role on the Azure OpenAI resource. Key based authentication is not supported for Azure OpenAI to avoid maintenance of secrets.
    1. For non- Azure, `OPENAI_API_KEY` - An OpenAI account and an [API key](https://platform.openai.com/account/api-keys) saved into a setting.  
    If using environment variables, Learn more in [.env readme](./env/README.md).
    1. Update `CHAT_MODEL_DEPLOYMENT_NAME` and `EMBEDDING_MODEL_DEPLOYMENT_NAME` keys to Azure Deployment names or override default OpenAI model names.
    1. If using user assigned managed identity, add `AZURE_CLIENT_ID` to environment variable settings with value as client id of the managed identity.
    1. Visit binding specific samples README for additional settings that might be required for each binding.
* Azure Storage emulator such as [Azurite](https://learn.microsoft.com/azure/storage/common/storage-use-azurite) running in the background
* The target language runtime (e.g. dotnet, nodejs, powershell, python, java) installed on your machine. Refer the official supported versions.

## Features

The following features are currently available. More features will be slowly added over time.

* [Text completions](#text-completion-input-binding)
* [Chat completion](#chat-completion)
* [Assistants](#assistants)
* [Embeddings generators](#embeddings-generator)
* [Semantic search](#semantic-search)

### Text completion input binding

The `textCompletion` input binding can be used to invoke the [OpenAI Chat Completions API](https://platform.openai.com/docs/guides/text-generation/chat-completions-vs-completions) and return the results to the function.

The examples below define "who is" HTTP-triggered functions with a hardcoded `"who is {name}?"` prompt, where `{name}` is the substituted with the value in the HTTP request path. The OpenAI input binding invokes the OpenAI GPT endpoint to surface the answer to the prompt to the function, which then returns the result text as the response content.

#### [C# example](./samples/textcompletion/csharp-ooproc/)

Setting a model is optional for non-Azure OpenAI, [see here](#default-openai-models) for default model values for OpenAI.

```csharp
[Function(nameof(WhoIs))]
public static HttpResponseData WhoIs(
    [HttpTrigger(AuthorizationLevel.Function, Route = "whois/{name}")] HttpRequestData req,
    [TextCompletionInput("Who is {name}?")] TextCompletionResponse response)
{
    HttpResponseData responseData = req.CreateResponse(HttpStatusCode.OK);
    responseData.WriteString(response.Content);
    return responseData;
}
```

#### [TypeScript example](./samples/textcompletion/nodejs/)

```typescript
import { app, input } from "@azure/functions";

// This OpenAI completion input requires a {name} binding value.
const openAICompletionInput = input.generic({
    prompt: 'Who is {name}?',
    maxTokens: '100',
    type: 'textCompletion',
    model: 'gpt-35-turbo'
})

app.http('whois', {
    methods: ['GET'],
    route: 'whois/{name}',
    authLevel: 'function',
    extraInputs: [openAICompletionInput],
    handler: async (_request, context) => {
        var response: any = context.extraInputs.get(openAICompletionInput)
        return { body: response.content.trim() }
    }
});
```

#### [PowerShell example](./samples/textcompletion/powershell/)

```PowerShell
using namespace System.Net

param($Request, $TriggerMetadata, $TextCompletionResponse)

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $TextCompletionResponse.Content
    })
```

In the same directory as the PowerShell function, define the bindings in a function.json file.  

If using Azure OpenAI, update `CHAT_MODEL_DEPLOYMENT_NAME` key in `local.settings.json` with the deployment name or update model property directly in function.json for textCompletion input binding or use it to override the default model value for OpenAI.

```json
{
    "type": "textCompletion",
    "direction": "in",
    "name": "TextCompletionResponse",
    "prompt": "Who is {name}?",
    "maxTokens": "100",
    "model": "gpt-3.5-turbo"
}
```

#### [Python example](./samples/textcompletion/python/)

Setting a model is optional for non-Azure OpenAI, [see here](#default-openai-models) for default model values for OpenAI.

```python
@app.route(route="whois/{name}", methods=["GET"])
@app.generic_input_binding(arg_name="response", type="textCompletion", data_type=func.DataType.STRING, prompt="Who is {name}?", maxTokens="100", model = "gpt-3.5-turbo")
def whois(req: func.HttpRequest, response: str) -> func.HttpResponse:
    response_json = json.loads(response)
    return func.HttpResponse(response_json["content"], status_code=200)
```

#### Running locally

You can run the above function locally using the Azure Functions Core Tools and sending an HTTP request, similar to the following:

```http
GET http://localhost:7127/api/whois/pikachu
```

The result that comes back will include the response from the GPT language model:

```text
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Date: Tue, 28 Mar 2023 18:25:40 GMT
Server: Kestrel
Transfer-Encoding: chunked

Pikachu is a fictional creature from the Pokemon franchise. It is a yellow
mouse-like creature with powerful electrical abilities and a mischievous
personality. Pikachu is one of the most iconic and recognizable characters
from the franchise, and is featured in numerous video games, anime series,
movies, and other media.
```

You can find more instructions for running the samples in the corresponding project directories. The goal is to have samples for all languages supported by Azure Functions.



### Assistants

Assistants build on top of the chat functionality to provide assistants with custom skills defined as functions.
This internally uses the [function calling](https://platform.openai.com/docs/guides/function-calling) feature of OpenAIs GPT models to select which functions to invoke and when.

You can define functions that can be triggered by assistants by using the `assistantSkillTrigger` trigger binding.
These functions are invoked by the extension when a assistant signals that it would like to invoke a function in response to a user prompt.

The name of the function, the description provided by the trigger, and the parameter name are all hints that the underlying language model use to determine when and how to invoke an assistant function.

#### [C# example](./samples/assistant/csharp-ooproc)

```csharp
public class AssistantSkills
{
    readonly ITodoManager todoManager;
    readonly ILogger<AssistantSkills> logger;

    // This constructor is called by the Azure Functions runtime's dependency injection container.
    public AssistantSkills(ITodoManager todoManager, ILogger<AssistantSkills> logger)
    {
        this.todoManager = todoManager ?? throw new ArgumentNullException(nameof(todoManager));
        this.logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    // Called by the assistant to create new todo tasks.
    [Function(nameof(AddTodo))]
    public Task AddTodo([AssistantSkillTrigger("Create a new todo task")] string taskDescription)
    {
        if (string.IsNullOrEmpty(taskDescription))
        {
            throw new ArgumentException("Task description cannot be empty");
        }

        this.logger.LogInformation("Adding todo: {task}", taskDescription);

        string todoId = Guid.NewGuid().ToString()[..6];
        return this.todoManager.AddTodoAsync(new TodoItem(todoId, taskDescription));
    }

    // Called by the assistant to fetch the list of previously created todo tasks.
    [Function(nameof(GetTodos))]
    public Task<IReadOnlyList<TodoItem>> GetTodos(
        [AssistantSkillTrigger("Fetch the list of previously created todo tasks")] object inputIgnored)
    {
        this.logger.LogInformation("Fetching list of todos");

        return this.todoManager.GetTodosAsync();
    }
}
```

## Introduction

AI assistants are chat bots that can be configured with custom skills. Custom skills are implemented using the `assistantSkillTrigger` binding.
Custom skills are useful ways to extend the functionality of an AI assistant. For example, you can create a custom skill that saves a todo item to a database, or a custom skill that queries a database for a list of todo items.
In both cases, the skills are defined in your app and any the language model doesn't need to know anything about the skill implementation, making it useful for interacting with private data.

This OpenAI extension internally uses the [function calling](https://platform.openai.com/docs/guides/function-calling) functionality available in
`gpt-3.5-turbo` and `gpt-4` models to implement assistant skills.

## Defining skills

You can define a skill by creating a function that uses the `AssistantSkillTrigger` binding. The following example shows a skill that adds a todo item to a database:

C# example:

```csharp
[Function(nameof(AddTodo))]
public Task AddTodo([AssistantSkillTrigger("Create a new todo task")] string taskDescription)
{
    if (string.IsNullOrEmpty(taskDescription))
    {
        throw new ArgumentException("Task description cannot be empty");
    }

    this.logger.LogInformation("Adding todo: {task}", taskDescription);

    string todoId = Guid.NewGuid().ToString()[..6];
    return this.todoManager.AddTodoAsync(new TodoItem(todoId, taskDescription));
}
```

Nodejs example:

```ts
app.generic('AddTodo', {
    trigger: trigger.generic({
        type: 'assistantSkillTrigger',
        functionDescription: 'Create a new todo task'
    }),
    handler: async (taskDescription: string, context: InvocationContext) => {
        if (!taskDescription) {
            throw new Error('Task description cannot be empty')
        }

        context.log(`Adding todo: ${taskDescription}`)

        const todoId = crypto.randomUUID().substring(0, 6)
        return todoManager.AddTodo(new TodoItem(todoId, taskDescription))
    }
})
```

The `AssistantSkillTrigger` attribute requires a `FunctionDescription` string value, which is text describing what the function does.
This is critical for the AI assistant to be able to invoke the skill at the right time.
The name of the function parameter (e.g., `taskDescription`) is also an important hint to the AI assistant about what kind of information to provide to the skill.

> **NOTE:** The `AssistantSkillTrigger` attribute only supports primitive types as function parameters, such as `string`, `int`, `bool`, etc. Function return values can be of any JSON-serializable type.

Any function that uses the `AssistantSkillTrigger` binding will be automatically registered as a skill that can be invoked by any AI assistant.
The assistant will invoke a skill function whenever it decides to do so to satisfy a user prompt, and will provide function parameters based on the context of the conversation. The skill function can then return a response to the assistant, which will be used to satisfy the user prompt.

## Prerequisites

The sample is available in the following language stacks:

* [C# on the out-of-process worker](csharp-ooproc)
* [nodejs](nodejs)

Please refer to this [Readme](https://github.com/Azure/azure-functions-openai-extension/blob/main/README.md) for common prerequisites that apply to all samples.

Additionally, if you want to run the sample with Cosmos DB, then you must also do the following:

* Install the [Azure Cosmos DB Emulator](https://docs.microsoft.com/azure/cosmos-db/local-emulator), or get a connection string to a real Azure Cosmos DB resource.
* Update the `CosmosDbConnectionString` setting in the `local.settings.json` file and configure it with the connection string to your Cosmos DB resource (local or Azure).

Also note that the storage of chat history is done via table storage. You may configure the `host.json` file within the project to be as follows:

```json
"extensions": {
    "openai": {
      "storageConnectionName": "AzureWebJobsStorage",
      "collectionName": "SampleChatState"
    }
}
```

`StorageConnectionName` is the name of connection string of a storage account and `CollectionName` is the name of the table that would hold the chat state and messages.

## Running the sample

1. Clone this [repo](https://github.com/Azure/azure-functions-openai-extension/tree/main) and navigate to the sample folder.
2. Use a terminal window to navigate to the sample directory (e.g. `cd samples/assistant/csharp-ooproc`)
3.  In the root project folder, run the [docker build](https://docs.docker.com/engine/reference/commandline/build/) command, and provide a name, azurefunctionsimage, and tag, v1.
> Note: Please make sure docker is running in your local
The following command builds the Docker image for the container.
```sh
docker build --platform linux --tag <DOCKER_ID>/<openaifuncimage>:<tag> .
```
## Local Testing
In this example, replace \<DOCKER_ID\> with your Docker Hub account ID. When the command completes, you can run the new container locally.

4\. To test the build, run the image in a local container using the [docker run](https://docs.docker.com/engine/reference/commandline/run/) command, with the adding the ports argument, -p 8080:80.
```sh
docker run \
-e AzureWebJobsStorage=<ManagedIdentity Id> \
-e CosmosDbConnectionString=<MI Id> \
-e CosmosDatabaseName=<todoDB> \
-e CosmosContainerName=<myTasks> \
-e AZURE_OPENAI_ENDPOINT= <Azure_Openai_endpoint>  \
-e AZURE_OPENAI_KEY=<Azure_client_id> \
-e CHAT_MODEL_DEPLOYMENT_NAME=<aoai_deployment_name> \
-p 8080:80 -it <DOCKER_ID>/<openaifuncimage>:<tag> .
```
Again, replace <DOCKER_ID with your Docker ID and adding the ports argument, -p 8080:80

    If successful, you should see the following output from the `docker run` command:

    ```plaintext
    Functions:

        CreateAssistant: [PUT] http://localhost:7168/api/assistants/{assistantId}

        GetChatState: [GET] http://localhost:7168/api/assistants/{assistantId}

        PostUserQuery: [POST] http://localhost:7168/api/assistants/{assistantId}

        AddTodo: assistantSkillTrigger

        GetTodos: assistantSkillTrigger
    ```

5\. After you've verified the function app in the container, stop docker with **Ctrl**+**C**.

Docker Hub is a container registry that hosts images and provides image and container services. To share your image, which includes deploying to Azure, you must push it to a registry.
**Docker login**

6\.  If you haven\'t already signed in to Docker, do so with the [docker login](https://docs.docker.com/engine/reference/commandline/login/) command, replacing  <docker_id> with your Docker ID. This command prompts you for your username and password. A "Login Succeeded" message confirms that you\'re signed in.

7\. After you\'ve signed in, push the image to Docker Hub by using the [docker push](https://docs.docker.com/engine/reference/commandline/push/) command, again replacing <docker_id> with your Docker ID.
```sh
docker push <DOCKER_ID>/<openaifuncimage>:<tag>
```
 8\. Depending on your network speed, pushing the image the first time might take a few minutes (pushing subsequent changes is much faster). While you\'re waiting, you can proceed to the next section and create Azure resources in another terminal.

 ## Deploy to Azure Functions

 1\. Head to the Azure Portal/AzCLI/ARM/Bicep deployment or follow instructions [here](https://learn.microsoft.com/en-us/azure/azure-functions/functions-how-to-custom-container?tabs=core-tools%2Cacr%2Cazure-cli2%2Cazure-cli&pivots=container-apps) to create an Azure Functions on Azure Container Apps resource.
 Make sure the function is successfully deployed.

 2\. Update the Azure functions AppSettings 

 ```sh
 AzureWebJobsStorage= <ManagedIdentity id> \
 CosmosDbConnectionString=<Azure_Client_id>  \
 CosmosDatabaseName=<todoDB> \
 CosmosContainerName=<myTasks> \
 AZURE_OPENAI_ENDPOINT=<Azure_openai_endpoint>  \
 AZURE_OPENAI_KEY=<Azure_client_id> \
 CHAT_MODEL_DEPLOYMENT_NAME=<aoai_deployment_name>
```

3\. Use an HTTP client tool to send a `PUT` request to the `CreateAssistant` function. The following is an example request:

    ```http
    PUT https://funcopenaiXXXXXXX.XXXXXXXXXXX-XXXXXXXXXX.XXXX.azurecontainerapps.io/api/assistants/{assistantId}
    ```

    > **NOTE:** The `assistant123` value is the unique ID of the assistant. You can use any value you like, but it must be unique and must be used consistently in all subsequent requests.

    > **NOTE:** All the HTTP requests in this sample can also be found in the [demo.http](demo.http) file, which can be opened and run in most IDEs.

    The HTTP response should look something like the following:

    ```json
    {"assistantId":"assistant123"}
    ```

    You should also see some relevant log output in the terminal window where the app is running.

    The AI assistant is now created and ready to receive prompts.

4\. Ask the assistant to create a todo item by sending a `POST` request to the `PostUserQuery` function to send a prompt to the assistant. The following is an example request:

    ```http
    POST https://funcopenaiXXXXXXX.XXXXXXXXXXX-XXXXXXXXXX.XXXX.azurecontainerapps.io/api/assistants/{assistantId}
    Content-Type: text/plain

    Remind me to call my dad
    ```

    The response should be an HTTP 202, indicating that the request was accepted. You should also see some relevant log output in the terminal window where the app is running.

    > **NOTE:** The AI assistant runs asynchronously in the background, so it doesn't respond immediately to prompts.  You should wait for about 10 seconds before sending subsequent messages to the assistant to give it time to finish processing the previous prompt.

    In the function log output, you should observe that the `AddTodo` function was triggered. This function is a custom skill that was automatically registered with the assistant when the app was started.

5\. Ask the assistant to create another todo item using another `POST` request to the `PostUserQuery` function. The following is an example request:

    ```http
    POST  https://funcopenaiXXXXXXX.XXXXXXXXXXX-XXXXXXXXXX.XXXX.azurecontainerapps.io/api/assistants/{assistantId}
    Content-Type: text/plain

    Oh, and to take out the trash
    ```

    The AI assistant remembers the context from the chat, so it knows that you're still talking about todo items, even if your prompt doesn't mention this explicitly.

6\. If you're running the sample with Cosmos DB persistence configured, then you can use the Cosmos DB Data Explorer to view the documents in the `my-todos` collection in the `testdb` database. You should see two documents, one for each todo item that the assistant created.

7\. Ask the assistant to list your todo items by sending a `POST` request to the `PostUserQuery` function. The following is an example request:

    ```http
    POST http://localhost:7168/api/assistants/assistant123
    Content-Type: text/plain

    What do I need to do today?
    ```

    The response should be an HTTP 202, indicating that the prompt was accepted. In the function log output, you should observe that the `GetTodos` function was triggered. This function is a custom skill that the assistant users to query any previously saved todos.

8\. Query the chat history by sending a `GET` request to the `GetChatState` function. The following is an example request:

    ```http
    GET http://localhost:7168/api/assistants/assistant123?timestampUTC=2023-01-01T00:00:00Z
    ```

    The response body should look something like the following:

    ```json
    {
      "id": "assistant123",
      "exists": true,
      "createdAt": "2023-11-26T00:40:56.7864809Z",
      "lastUpdatedAt": "2023-11-26T00:41:21.0153489Z",
      "totalMessages": 10,
      "totalTokens": 153,
      "recentMessages": [
        {
          "role": "system",
          "content": "Don't make assumptions about what values to plug into functions.\r\nAsk for clarification if a user request is ambiguous.",
        },
        {
          "role": "user",
          "content": "Remind me to call my dad"
        },
        {
          "role": "function",
          "content": "The function call succeeded. Let the user know that you completed the action.",
        },
        {
          "role": "assistant",
          "content": "I have added a reminder for you to call your dad."
        },
        {
          "role": "user",
          "content": "Oh, and to take out the trash"
        },
        {
          "role": "function",
          "content": "The function call succeeded. Let the user know that you completed the action.",
        },
        {
          "role": "assistant",
          "content": "I have added a reminder for you to take out the trash."
        },
        {
          "role": "user",
          "content": "What do I need to do today?"
        },
        {
          "role": "function",
          "content": "[{\"Id\":\"4d3170\",\"Task\":\"Call my dad\"},{\"Id\":\"f1413f\",\"Task\":\"Take out the trash\"}]",
        },
        {
          "role": "assistant",
          "content": "Today, you need to:\n- Call your dad\n- Take out the trash"
        }
      ]
    }
    ```

    > **NOTE**: Notice that the list of messages comes from four different roles, `system`, `user`, `assistant`, and `function`. Of these, only messages created by `user` and `assistant` should be displayed to end users. Messages created by `system` and `function` are auto-generated and should not be displayed.

As you can hopefully see, the assistant acknowledged the two todo items that you created, and then listed them back to you when you asked for your todo list. The interaction effectively looked something like the following:

> **USER**: Remind me to call my dad
>
> **ASSISTANT**: I have added a reminder for you to call your dad.
>
> **USER**: Oh, and to take out the trash
>
> **ASSISTANT**: I have added a reminder for you to take out the trash.
>
> **USER**: What do I need to do today?
>
> **ASSISTANT**: Today, you need to:
>
> * Call your dad
> * Take out the trash



## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
