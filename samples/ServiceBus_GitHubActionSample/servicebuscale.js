const { ServiceBusClient } = require("@azure/service-bus");

// connection string to your Service Bus namespace
const connectionString = "<connection_string"


// name of the queue
const queueName = "lower-case" 


 async function main() {
	const sbClient = new ServiceBusClient(connectionString);
  
	// createSender() can also be used to create a sender for a topic.
	const sender = sbClient.createSender(queueName);
  
	try {
		for(let n=0; n < 100; n++) 
		{
		console.log(`Sending scientists`);
		const message = {
		  contentType: "application/json",
		  subject: "Scientist",
		  body: { firstName: "albert", lastName: "einstein" },
		  timeToLive: 1 * 60 * 1000, // message expires in 2 minutes
		};
		await sender.sendMessages(message);
	}
	
		// Close the sender
		console.log(`Done sending, closing...`);
		await sender.close();
	}
	finally {
		await sbClient.close();
	  }
	}
 
// call the main function
main().catch((err) => {
	console.log("Error occurred: ", err);
	process.exit(1);
 });
