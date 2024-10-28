import azure.functions as func
import logging
import os

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="http_trigger")
def http_trigger(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    file_path = os.path.join("/mount-path", 'myfile.txt')
    logging.info(f"File path: {file_path}")
    name = req.params.get('name')
    if name:
        try:
            # Open and read the file
            with open(file_path, 'w+') as file:
                file.write(name)
            
            # Return the content of the file as the response
            return func.HttpResponse("wrote sucessfully to the file", status_code=200)
        
        except Exception as e:
            # Handle any errors that occur
            return func.HttpResponse(f"Error: {str(e)}", status_code=500)

    if not name:
        try:
            # Open and read the file
            with open(file_path, 'r') as file:
                content = file.read()
            
            # Return the content of the file as the response
            return func.HttpResponse(content, status_code=200)
        
        except Exception as e:
            # Handle any errors that occur
            return func.HttpResponse(f"Error: {str(e)}", status_code=500)

    