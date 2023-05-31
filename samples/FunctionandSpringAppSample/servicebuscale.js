const { ServiceBusClient } = require("@azure/service-bus");

// connection string to your Service Bus namespace
const connectionString ="Endpoint=sb://funconacademosbnamespace.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=5jCFtxepdd1QzCZBuvJjoOLgGxSLmuhKA+ASbPrHijY="


// name of the queue
const queueName = "lower-case" 

/*
const messages = [{body: "Convert me to uppercase 1"},
{body: "Convert me to uppercase 2"},
{body: "Convert me to uppercase 3"},
{body: "Convert me to uppercase 4"},
{body: "Convert me to uppercase 5"},
{body: "Convert me to uppercase 6"},
{body: "Convert me to uppercase 7"},
{body: "Convert me to uppercase 2"},
{body: "Convert me to uppercase 3"},
{body: "Convert me to uppercase 4"},
{body: "Convert me to uppercase 5"},
{body: "Convert me to uppercase 6"},
{body: "Convert me to uppercase 7"},
{body: "Convert me to uppercase 2"},
{body: "Convert me to uppercase 3"},
{body: "Convert me to uppercase 4"},
{body: "Convert me to uppercase 5"},
{body: "Convert me to uppercase 6"},
{body: "Convert me to uppercase 7"}
];

/*[
	{ body: "Albert Einstein" },
	{ body: "Werner Heisenberg" },
	{ body: "Marie Curie" },
	{ body: "Steven Hawking" },
	{ body: "Isaac Newton" },
	{ body: "Niels Bohr" },
	{ body: "Michael Faraday" },
	{ body: "Galileo Galilei" },
	{ body: "Johannes Kepler" },
	{ body: "Nikolaus Kopernikus" }
 ];  */
 

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
		  body: { firstName: "convert albert to uppercase", lastName: "convert einstein to uppercase" },
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

 /* - start here

async function main() {
	// create a Service Bus client using the connection string to the Service Bus namespace
	const sbClient = new ServiceBusClient(connectionString);

	// createSender() can also be used to create a sender for a topic.
	const sender = sbClient.createSender(queueName);
	
	try {
		// Tries to send all messages in a single batch.
		// Will fail if the messages cannot fit in a batch.
		// await sender.sendMessages(messages);
        for(let n=0; n < 10000; n++) 
	{
		// create a batch object
		let batch = await sender.createMessageBatch(); 
		for (let i = 0; i <  messages.length; i++) {
			// for each message in the array			

			// try to add the message to the batch
			if (!batch.tryAddMessage(messages[i])) {			
				// if it fails to add the message to the current batch
				// send the current batch as it is full
				await sender.sendMessages(batch);

				// then, create a new batch 
				batch = await sender.createMessageBatch();

				// now, add the message failed to be added to the previous batch to this batch
				if (!batch.tryAddMessage(messages[i])) {
					// if it still can't be added to the batch, the message is probably too big to fit in a batch
					throw new Error("Message too big to fit in a batch");
				}
			}
		}

		// Send the last created batch of messages to the queue
		await sender.sendMessages(batch);

		console.log(`Sent a batch of messages to the queue: ${queueName}`);

	}

		// Close the sender
		await sender.close();
	
	}
	finally {
		await sbClient.close();
	}
} 
end here*/ 

// call the main function
main().catch((err) => {
	console.log("Error occurred: ", err);
	process.exit(1);
 });