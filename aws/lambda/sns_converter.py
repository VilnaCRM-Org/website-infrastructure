import boto3
import os
import json

sns_topic_arn = os.environ["SNS_TOPIC_ARN"]
client = boto3.client('sns')

def lambda_handler(event, context):
    message = {
            "version": "1.0",
            "source": "custom",
            "content": {
                "description": ":Some of the files were deleted*! \ncc: @SRE-Team"
        }
    }

    response = client.publish(TopicArn=sns_topic_arn,MessageStructure='json',Message=json.dumps({'default': json.dumps(message)}))
    return response
    