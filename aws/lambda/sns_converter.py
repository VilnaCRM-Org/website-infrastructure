import boto3
import os
import json

sns_topic_arn = os.environ["SNS_TOPIC_ARN"]
client = boto3.client('sns')

def lambda_handler(event, context):
    message = {
        "default": "Some of the files were deleted!",
        "https": {
            "version": "1.0",
            "source": "custom",
            "content": {
                "description": ":warning: EC2 auto scaling refresh failed for ASG *OrderProcessorServiceASG*! \ncc: @SRE-Team"
            }
        },
        "email": {
            "version": "1.0",
            "source": "custom",
            "content": {
                "description": ":warning: EC2 auto scaling refresh failed for ASG *OrderProcessorServiceASG*! \ncc: @SRE-Team"
            }
        }
    }

    response = client.publish(TopicArn=sns_topic_arn,MessageStructure='json',Message=json.dumps(message))
    print('Hello from Lambda!')
    return response