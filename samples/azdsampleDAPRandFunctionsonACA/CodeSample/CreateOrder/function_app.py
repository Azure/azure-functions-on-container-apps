import json
import azure.functions as func
import logging

dapp = func.DaprFunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

# Dapr service invocation trigger
@dapp.function_name(name="CreateOrder")
@dapp.dapr_service_invocation_trigger(arg_name="payload", method_name="CreateOrder")
@dapp.dapr_state_outreput(arg_name="state", state_store="%StateStoName%", key="order")
def main(payload: str, state: func.Out[str] ) :
   
    logging.info('Azure function triggered by Dapr Service Invocation Trigger.')
    logging.info("Dapr service invocation trigger payload: %s", payload)
    state.set(payload)

