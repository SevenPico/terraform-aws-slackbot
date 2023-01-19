import json
import urllib3
import os
import re
import boto3

import config

config  = config.Config()
http    = urllib3.PoolManager()
session = boto3.Session()

def get_slack_token(secret_arn):
    client = session.client('secretsmanager')
    response = client.get_secret_value(
        SecretId = secret_arn
    )
    return response['SecretString']

SLACK_URL = 'https://slack.com/api'
SLACK_TOKEN = get_slack_token(config.slack_secret_arn)


def lambda_handler(event, context):
    print(f'Lambda Input Event: {event}')
    print(f'Lambda Input Context: {context}')

    e = json.loads(event['Records'][0]['Sns']['Message'])
    print(f'Event: {e}')

    topic = e.get('topic', 'ALERT').upper()
    msg = e.get('message', 'No message provided by event source :(')
    context_id = e.get('context_id', None)

    if context_id != None:
        pass # TODO look up slack thread from dynamodb table @context_id
        # set the ts field on msg

    # Look up channel id by topic
    msg['channel'] = config.slack_channels[topic]

    print('Slack Message:', msg)

    response = http.request('POST', f'{SLACK_URL}/chat.postMessage',
        body = json.dumps(msg).encode('utf-8'),
        headers = {
            'Content-type': 'application/json; charset=utf-8',
            'Authorization': f'Bearer {SLACK_TOKEN}',
        },
    )

    print('Slack Response:', response)

    # TODO - store response in dynamodb table @context_id
