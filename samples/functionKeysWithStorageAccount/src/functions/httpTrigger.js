const { app } = require('@azure/functions');

// Authenticated endpoint with function-level authentication
app.http('httpTrigger', {
    methods: ['GET', 'POST'],
    authLevel: 'function', // Requires function key authentication
    handler: async (request, context) => {
        try {
            context.log('Authenticated HTTP trigger function processed a request.');
            
            const name = request.query.get('name') || 'World';
            
            return {
                status: 200,
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    message: `Hello, ${name}! Authenticated function executed successfully!`,
                    timestamp: new Date().toISOString(),
                    note: 'Function running in Container Apps with Azure Storage',
                    authLevel: 'function',
                    endpoint: '/api/httpTrigger',
                    conclusion: 'Authentication required - need valid function key'
                }, null, 2)
            };
        } catch (error) {
            context.log.error('Error in authenticated function:', error);
            return {
                status: 500,
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    error: 'Internal server error',
                    message: error.message,
                    timestamp: new Date().toISOString()
                }, null, 2)
            };
        }
    }
});

// Anonymous endpoint for testing
app.http('healthCheck', {
    methods: ['GET', 'POST'],
    authLevel: 'anonymous',
    route: 'health',
    handler: async (request, context) => {
        try {
            context.log('Anonymous health check function processed a request.');
            
            const name = request.query.get('name') || 'Anonymous User';
            
            return {
                status: 200,
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    message: `Hello, ${name}! Anonymous function executed successfully!`,
                    timestamp: new Date().toISOString(),
                    note: 'This endpoint requires no authentication',
                    authLevel: 'anonymous',
                    endpoint: '/api/health',
                    status: 'healthy'
                }, null, 2)
            };
        } catch (error) {
            context.log.error('Error in anonymous function:', error);
            return {
                status: 500,
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    error: 'Internal server error',
                    message: error.message,
                    timestamp: new Date().toISOString()
                }, null, 2)
            };
        }
    }
});