import json
import logging
import os


def log():
    log = logging.getLogger()
    log.setLevel(os.getenv('LOG_LEVEL', logging.WARNING))
    return log


def proxy_data(data, code=200):
    retval = {
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json",
            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': '*'
        },
        "body": json.dumps(data)
    }

    log().info('Return data: %s', json.dumps(retval))
    return retval
