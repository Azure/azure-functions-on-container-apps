# Use the official Azure Functions Node.js base image
FROM mcr.microsoft.com/azure-functions/node:4-node18-appservice

# Set environment variables required by Azure Functions
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    WEBSITE_HOSTNAME=localhost

# Copy package files first (for better Docker layer caching)
COPY package*.json /home/site/wwwroot/

# Set working directory
WORKDIR /home/site/wwwroot

# Create a non-root user for security (if base image doesn't already provide one)
RUN groupadd -r azureuser \
    && useradd -r -g azureuser -d /home/site/wwwroot -s /sbin/nologin azureuser

# Ensure the Functions runtime can create /azure-functions-host/Secrets and make the app secrets directory
# owned by the non-root user so no runtime root privileges are required.
RUN mkdir -p /azure-functions-host \
    && chown -R azureuser:azureuser /azure-functions-host

# Install dependencies (production only for smaller image)
RUN npm ci --only=production && \
    npm cache clean --force

# Copy application files
COPY . /home/site/wwwroot/

# Create an application-local secrets directory and set correct ownership
RUN mkdir -p /home/site/wwwroot/.azurefunctions-host \
    && chown -R azureuser:azureuser /home/site/wwwroot/.azurefunctions-host

# Change ownership of the working directory and ensure proper permissions
RUN chown -R azureuser:azureuser /home/site/wwwroot \
    && chown -R azureuser:azureuser /azure-functions-host

# Switch to non-root user for security
USER azureuser

# Configure Azure Functions to use port 8080 without requiring privileged access
ENV ASPNETCORE_URLS=http://0.0.0.0:8080
ENV WEBSITE_HOSTNAME=0.0.0.0:8080
ENV PORT=8080
EXPOSE 8080