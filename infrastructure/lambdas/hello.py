import logging
import os
import json

log = logging.getLogger(__name__)


def handler(event, context):
    log.error('Got event data: %s', event)
    json_region = os.environ['AWS_REGION']
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "Region ": json_region
        })
    }
