using System;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace ServiceBusProj
{
    public class ServiceBusExample
    {
        private readonly ILogger _logger;

        public ServiceBusExample(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<ServiceBusExample>();
        }

        [Function("ServiceBusExample")]
        public void Run([ServiceBusTrigger("upper-case", Connection = "AzureWebJobsServiceBus")] string myQueueItem)
        {
            _logger.LogInformation($"C# ServiceBus queue trigger function processed message: {myQueueItem}");
        }
    }
}
