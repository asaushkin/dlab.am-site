import json
import os
import utils

# Three steps to create a new lambda function:
# 1. Create a new python function based on this code (remember a new file name)
# 2. Create a part in terraform lambda.tf file
# 3. Add API gateway endpoint and link API integration with terraform code


def handler(event, context):
    utils.log().info('Got event data: %s', json.dumps(event))
    utils.log().debug('Environ: %s', os.environ)

    return utils.proxy_data({
        "region": os.environ['AWS_REGION']
    })
