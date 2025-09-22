const { app } = require('@azure/functions');

// In-memory array to store upload info
const uploadsHeap = [];

// Blob Trigger: Fires on every new upload
app.storageBlob('BlobTriggerFunction', {
    path: 'uploads/{name}',
    connection: 'AzureWebJobsStorage',
    handler: async (blob, context) => {
        const fileName = context.triggerMetadata.name;
        const fileSize = blob.length;
        const timestamp = new Date().toISOString();

        const uploadInfo = {
            fileName,
            fileSize,
            uploadTime: timestamp,
            containerPath: `uploads/${fileName}`, //make sure the files are uploaded in the 'uploads' folder in the Storage container
            metadata: context.triggerMetadata
        };

        context.log('New blob uploaded:', uploadInfo);

        // Store in memory
        uploadsHeap.push(uploadInfo);
    }
});

// HTTP Trigger: Get all uploaded file records from memory
app.http('GetUploads', {
    methods: ['GET'],
    authLevel: 'anonymous',
    handler: async (request, context) => {
        return {
            status: 200,
            jsonBody: uploadsHeap
        };
    }
});
