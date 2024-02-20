using System;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Microsoft.Azure.WebJobs;

namespace TimerProject
{
    public class timerfunc
    {
        private readonly ILogger _logger;

        public timerfunc(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<timerfunc>();
        }

        [Function("timerfunc")]
        public void Run([TimerTrigger("0 */1 * * * *")] TimerInfo myTimer)
        {
            _logger.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");
            
            if (myTimer.ScheduleStatus is not null)
            {
                _logger.LogInformation($"Next timer schedule at: {myTimer.ScheduleStatus.Next}");
            }
        }
    }
}
