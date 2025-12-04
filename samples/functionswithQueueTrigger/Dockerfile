# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 as build

# Set the working directory for build
WORKDIR /src

# Copy project file
COPY QueueTriggerFunction.csproj ./

# Restore dependencies
RUN dotnet restore

# Copy source code
COPY . ./

# Build and publish the application
RUN dotnet publish -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/azure-functions/dotnet-isolated:4-dotnet-isolated8.0 as runtime

# Set the working directory
WORKDIR /home/site/wwwroot

# Copy published application from build stage
COPY --from=build /app/publish .

# Copy configuration files
COPY host.json ./
COPY local.settings.json ./

# Set environment variables for Azure Functions
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    FUNCTIONS_WORKER_RUNTIME=dotnet-isolated \
    ASPNETCORE_URLS=http://+:80

# Expose port 80
EXPOSE 80

# Use the default entry point from the base image
# The base image already has the proper setup for Azure Functions