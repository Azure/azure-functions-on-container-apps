const { app } = require('@azure/functions');

app.storageBlob('BlobTriggerFunction', {
    path: 'uploads/{name}',
    connection: 'AzureWebJobsStorage',
    handler: async (blob, context) => {
        const fileName = context.triggerMetadata.name;
        const fileSize = blob.length;
        const timestamp = new Date().toISOString();
        
        context.log(`New blob uploaded!`);
        context.log(`File name: ${fileName}`);
        context.log(`File size: ${fileSize} bytes`);
        context.log(`Upload time: ${timestamp}`);
        context.log(`Container path: uploads/${fileName}`);
        
        // Log blob metadata if available
        if (context.triggerMetadata) {
            context.log(`📋 Trigger metadata:`, JSON.stringify(context.triggerMetadata, null, 2));
        }
    }
});