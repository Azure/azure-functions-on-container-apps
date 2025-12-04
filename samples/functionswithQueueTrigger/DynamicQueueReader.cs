using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Azure.Storage.Queues;
using System.Net;
using System.Text.Json;

namespace QueueTriggerFunction;

public class DynamicQueueReader
{
    private readonly ILogger<DynamicQueueReader> _logger;
    private readonly string _connectionString;

    public DynamicQueueReader(ILogger<DynamicQueueReader> logger)
    {
        _logger = logger;
        _connectionString = Environment.GetEnvironmentVariable("AzureWebJobsStorage") ?? "UseDevelopmentStorage=true";
    }

    [Function("ReadFromQueue")]
    public async Task<HttpResponseData> ReadFromQueue(
        [HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequestData req)
    {
        _logger.LogInformation("ReadFromQueue function processed a request.");

        try
        {
            // Get queue name from query parameter only
            string? queueName = req.Query["queueName"];

            if (string.IsNullOrEmpty(queueName))
            {
                var badRequestResponse = req.CreateResponse(HttpStatusCode.BadRequest);
                await badRequestResponse.WriteStringAsync("Queue name is required. Provide it as 'queueName' query parameter.");
                return badRequestResponse;
            }

            // Get number of messages to read (default: 1, max: 32)
            int messageCount = 1;
            if (int.TryParse(req.Query["count"], out int parsedCount))
            {
                messageCount = Math.Min(Math.Max(parsedCount, 1), 32);
            }

            // Read messages from the specified queue
            var messages = await ReadMessagesFromQueue(queueName, messageCount);

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json");

            var result = new QueueReadResponse
            {
                QueueName = queueName,
                MessageCount = messages.Count,
                Messages = messages,
                Timestamp = DateTime.UtcNow
            };

            await response.WriteStringAsync(JsonSerializer.Serialize(result, new JsonSerializerOptions 
            { 
                WriteIndented = true 
            }));

            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error reading from queue");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteStringAsync($"Error: {ex.Message}");
            return errorResponse;
        }
    }



    [Function("ListQueues")]
    public async Task<HttpResponseData> ListQueues(
        [HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequestData req)
    {
        _logger.LogInformation("ListQueues function processed a request.");

        try
        {
            var queueServiceClient = new QueueServiceClient(_connectionString);
            var queues = new List<string>();

            await foreach (var queueItem in queueServiceClient.GetQueuesAsync())
            {
                queues.Add(queueItem.Name);
            }

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json");

            var result = new
            {
                Queues = queues,
                Count = queues.Count,
                Timestamp = DateTime.UtcNow
            };

            await response.WriteStringAsync(JsonSerializer.Serialize(result, new JsonSerializerOptions 
            { 
                WriteIndented = true 
            }));

            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error listing queues");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteStringAsync($"Error: {ex.Message}");
            return errorResponse;
        }
    }

    private async Task<List<QueueMessageInfo>> ReadMessagesFromQueue(string queueName, int messageCount)
    {
        var queueClient = new QueueClient(_connectionString, queueName);
        
        // Create queue if it doesn't exist
        await queueClient.CreateIfNotExistsAsync();

        var messages = new List<QueueMessageInfo>();
        
        // Peek messages (doesn't remove them from queue)
        var peekedMessages = await queueClient.PeekMessagesAsync(messageCount);
        
        foreach (var message in peekedMessages.Value)
        {
            messages.Add(new QueueMessageInfo
            {
                MessageId = message.MessageId,
                MessageText = message.Body.ToString(),
                InsertionTime = message.InsertedOn,
                ExpirationTime = message.ExpiresOn
            });
        }

        _logger.LogInformation($"Read {messages.Count} messages from queue '{queueName}'");
        return messages;
    }


}

public class QueueRequest
{
    public string QueueName { get; set; } = string.Empty;
}



public class QueueReadResponse
{
    public string QueueName { get; set; } = string.Empty;
    public int MessageCount { get; set; }
    public List<QueueMessageInfo> Messages { get; set; } = new();
    public DateTime Timestamp { get; set; }
}

public class QueueMessageInfo
{
    public string MessageId { get; set; } = string.Empty;
    public string MessageText { get; set; } = string.Empty;
    public DateTimeOffset? InsertionTime { get; set; }
    public DateTimeOffset? ExpirationTime { get; set; }
}

// Traditional Queue Trigger Functions
public class OrderProcessor
{
    private readonly ILogger<OrderProcessor> _logger;

    public OrderProcessor(ILogger<OrderProcessor> logger)
    {
        _logger = logger;
    }

    /// <summary>
    /// Traditional QueueTrigger - automatically processes messages from the "orders" queue
    /// This demonstrates the classic Azure Functions queue trigger programming model
    /// </summary>
    [Function("ProcessOrder")]
    public void ProcessOrder([QueueTrigger("orders")] string orderMessage)
    {
        _logger.LogInformation($"Processing order: {orderMessage}");
        
        try
        {
            // Parse the order message
            var order = JsonSerializer.Deserialize<OrderMessage>(orderMessage);
            if (order != null)
            {
                _logger.LogInformation($"Order ID: {order.OrderId}, Customer: {order.CustomerName}, Amount: ${order.Amount}");
                
                // Simulate order processing
                ProcessOrderLogic(order);
                
                _logger.LogInformation($"Successfully processed order {order.OrderId}");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error processing order message: {orderMessage}");
            throw; // This will move the message to the poison queue after retries
        }
    }

    /// <summary>
    /// Another QueueTrigger - processes notification messages
    /// </summary>
    [Function("ProcessNotification")]
    public async Task ProcessNotification([QueueTrigger("notifications")] string notificationMessage)
    {
        _logger.LogInformation($"Processing notification: {notificationMessage}");
        
        try
        {
            var notification = JsonSerializer.Deserialize<NotificationMessage>(notificationMessage);
            if (notification != null)
            {
                _logger.LogInformation($"Sending {notification.Type} notification to {notification.Recipient}");
                
                // Simulate async notification sending
                await SendNotificationAsync(notification);
                
                _logger.LogInformation($"Successfully sent notification to {notification.Recipient}");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error processing notification: {notificationMessage}");
            throw;
        }
    }

    private void ProcessOrderLogic(OrderMessage order)
    {
        // Simulate order processing time
        Thread.Sleep(100);
        
        // Here you would typically:
        // 1. Validate the order
        // 2. Check inventory
        // 3. Process payment
        // 4. Update database
        // 5. Send confirmation
    }

    private async Task SendNotificationAsync(NotificationMessage notification)
    {
        // Simulate async notification sending
        await Task.Delay(50);
        
        // Here you would typically:
        // 1. Send email/SMS/push notification
        // 2. Log the notification
        // 3. Update notification status
    }
}

// Message Models for Queue Triggers
public class OrderMessage
{
    public string OrderId { get; set; } = string.Empty;
    public string CustomerName { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public List<string> Items { get; set; } = new();
    public DateTime OrderDate { get; set; }
}

public class NotificationMessage
{
    public string Type { get; set; } = string.Empty; // email, sms, push
    public string Recipient { get; set; } = string.Empty;
    public string Subject { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public Dictionary<string, string> Metadata { get; set; } = new();
}