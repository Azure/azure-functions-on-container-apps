const { app } = require('@azure/functions');

// In-memory storage for events (in production, use a database or storage)
let eventStore = [];

// Event Grid webhook - handles validation and stores events
app.http('eventGridTrigger', {
    methods: ['POST'],
    authLevel: 'anonymous',
    handler: async (request, context) => {
        context.log('Event Grid webhook function processed a request.');
        
        try {
            const events = await request.json();
            context.log('Received events:', JSON.stringify(events, null, 2));

            // Handle Event Grid validation handshake
            if (events && events.length > 0 && events[0].eventType === 'Microsoft.EventGrid.SubscriptionValidationEvent') {
                context.log('Handling Event Grid validation event');
                const validationCode = events[0].data.validationCode;
                
                return {
                    status: 200,
                    headers: { 'Content-Type': 'application/json' },
                    jsonBody: { validationResponse: validationCode }
                };
            }

            // Process regular Event Grid events
            for (const eventGridEvent of events) {
                const eventData = {
                    id: eventGridEvent.id,
                    eventType: eventGridEvent.eventType,
                    subject: eventGridEvent.subject,
                    eventTime: eventGridEvent.eventTime,
                    data: eventGridEvent.data,
                    dataVersion: eventGridEvent.dataVersion,
                    metadataVersion: eventGridEvent.metadataVersion,
                    processedAt: new Date().toISOString()
                };

                eventStore.push(eventData);
                context.log('Event stored successfully:', eventData.id);
            }
            
            // Keep only last 100 events
            if (eventStore.length > 100) {
                eventStore = eventStore.slice(-100);
            }

            return {
                status: 200,
                jsonBody: { message: 'Events processed successfully', count: events.length }
            };
            
        } catch (error) {
            context.log.error('Error processing Event Grid webhook:', error.message);
            return {
                status: 500,
                jsonBody: { error: 'Internal server error', details: error.message }
            };
        }
    }
});

// HTTP trigger - retrieves stored events
app.http('eventGridHttp', {
    methods: ['GET'],
    authLevel: 'anonymous',
    handler: async (request, context) => {
        context.log('HTTP trigger for Event Grid data retrieval processed a request.');

        try {
            return {
                status: 200,
                jsonBody: {
                    message: 'Event Grid events retrieved successfully',
                    timestamp: new Date().toISOString(),
                    totalEvents: eventStore.length,
                    events: eventStore.map(event => ({
                        id: event.id,
                        eventType: event.eventType,
                        subject: event.subject,
                        eventTime: event.eventTime,
                        processedAt: event.processedAt,
                        data: event.data
                    }))
                }
            };

        } catch (error) {
            context.log.error('Error in HTTP trigger:', error.message);
            return {
                status: 500,
                jsonBody: {
                    error: 'Internal server error',
                    details: error.message
                }
            };
        }
    }
});

module.exports = app;
