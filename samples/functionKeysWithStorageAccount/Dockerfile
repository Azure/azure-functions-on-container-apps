# Build stage
FROM mcr.microsoft.com/azure-functions/node:4-node22-appservice as build

# Set the working directory for build
WORKDIR /home/site/wwwroot

# Copy package.json
COPY package*.json ./

# Install production dependencies
RUN npm install --omit=dev

# Copy source code
COPY host.json ./
COPY local.settings.json ./
COPY src/ ./src/

# Runtime stage
FROM mcr.microsoft.com/azure-functions/node:4-node22-appservice as runtime

# Set the working directory
WORKDIR /home/site/wwwroot

# Copy only production dependencies and compiled code from build stage
COPY --from=build /home/site/wwwroot/node_modules ./node_modules
COPY --from=build /home/site/wwwroot/package*.json ./
COPY --from=build /home/site/wwwroot/host.json ./
COPY --from=build /home/site/wwwroot/local.settings.json ./
COPY --from=build /home/site/wwwroot/src ./src

# Set environment variables for Azure Functions
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    FUNCTIONS_WORKER_RUNTIME=node

# Expose port 80
EXPOSE 80

# Use the default entry point from the base image (runs as root, which is needed for port 80)
# The base image already has the proper setup for Azure Functions