import json
import azure.functions as func
import logging


dapp = func.DaprFunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

# Service invoke another Dapr API
@dapp.function_name(name="InvokeOutputBinding")
@dapp.route(route="invoke", auth_level=dapp.auth_level.ANONYMOUS)
@dapp.dapr_invoke_output(arg_name = "payload", app_id = "%Appid%", method_name = "%methodname%", http_verb = "post")

# Python Http Azure Function
def main(req: func.HttpRequest, payload: func.Out[str] ) -> str:
   
     
    logging.info('Python HTTP trigger function processed a request..')
    logging.info(req.params)
    data = req.params.get('data')
    if not data:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            data = req_body.get('data')

    if data:
        logging.info(f"Url: {req.url}, Data: {data}")
        payload.set(json.dumps({"body": data}).encode('utf-8'))
        return 'Successfully performed service invocation using Dapr invoke output binding.'
    else:
        return func.HttpResponse(
            "Please pass a data on the query string or in the request body",
            status_code=400
        )