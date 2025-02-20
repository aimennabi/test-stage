import json
import os

from lambda_app.app import lambda_handler

def load_event(file_name):
    with open(os.path.join('events', file_name), 'r') as file:
        return json.load(file)

def test_lambda_handler_success():
    event = load_event('event.json')
    context = {}
    response = lambda_handler(event, context)
    body = json.loads(response['body'])

    assert response['statusCode'] == 200
    assert body['result'] == "The received message is: 'hello world'"

def test_lambda_handler_missing_body():
    event = load_event('event_missing_body.json')
    context = {}
    response = lambda_handler(event, context)
    body = json.loads(response['body'])

    assert response['statusCode'] == 400
    assert body['error'] == "Missing 'body' in event."

def test_lambda_handler_invalid_json():
    event = load_event('event_no_message.json')
    context = {}
    response = lambda_handler(event, context)
    body = json.loads(response['body'])

    assert response['statusCode'] == 400
    assert body['error'] == "Missing 'message' key in request body."