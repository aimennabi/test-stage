"""Entry points for the application."""
import json
import logging
from typing import Union

logger = logging.getLogger()
logger.setLevel('INFO')


def process(message: str) -> str:
    """Process message. The application logic is impleted here.
    Nothing to implement for the assessment.
    """
    return f"The received message is: '{message}'"


JSON = dict[str, Union[int, str, float, 'JSON']]

LambdaEvent = JSON
LambdaContext = object
LambdaOutput = JSON


def lambda_handler(event: LambdaEvent, context: LambdaContext) -> LambdaOutput:  # noqa: ARG001
    """Entry point for Lambda function.

    Parameters
    ----------
    event: dict, required
        API Gateway Lambda Proxy Input Format

        Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format

    context: object, required
        Lambda Context runtime methods and attributes

        Context doc: https://docs.aws.amazon.com/lambda/latest/dg/python-context-object.html

    Returns
    -------
    API Gateway Lambda Proxy Output Format: dict

        Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
    """
    try:
        #  write the lambda handler in a *robust* manner to:
        # - fetch the message in the event body of the LambdaEvent
        # - call the above 'process' function with the message and get value
        # - return the LambdaOutput with the following format:
        #       'statusCode',
        #       'body': 'Return_value_of_process_function'
        if 'body' not in event:
            logger.error("Missing 'body' in event.")
            return {
                'statusCode': 400,
                'body': json.dumps({'error': "Missing 'body' in event."}),
            }
        # Récupère le body et essaie de le parser en JSON
        try:
            body = json.loads(event['body'])
        except json.JSONDecodeError:
            logger.exception("Invalid JSON in 'body'.")
            return {
                'statusCode': 400,
                'body': json.dumps({'error': "Invalid JSON in 'body'."}),
            }
        # Vérifie que la clé 'message' est présente
        if 'message' not in body:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': "Missing 'message' key in request body."}),
            }
        # Traite le message avec la fonction process
        message = body['message']
        result = process(message)
        # Retourne la réponse avec un statut 200
        return {
            'statusCode': 200,
            'body': json.dumps({'result': result}),
        }
    except Exception:
        logger.exception('Internal server error')
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal server error'}),
        }
