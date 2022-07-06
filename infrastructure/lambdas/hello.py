import json
import os
import utils

def handler(event, context):
    utils.log().info('Got event data: %s', json.dumps(event))
    utils.log().debug('Environ: %s', os.environ)

    return utils.proxy_data({
        "Region ": os.environ['AWS_REGION']
    })
