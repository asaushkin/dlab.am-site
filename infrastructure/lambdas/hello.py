import json
import logging
import os
import utils

log = logging.getLogger(__name__)
log.setLevel(os.getenv('LOG_LEVEL', logging.WARNING))


def handler(event, context):
    log.debug('Got event data: %s', json.dumps(event))

    return utils.proxy_data({
        "Region ": os.environ['AWS_REGION']
    }, log)
