import boto3
import os
import json

sns_topic_arn = os.environ["SNS_TOPIC_ARN"]
client = boto3.client('sns')

def lambda_handler(event, context):
    
    buckets_link = "<https://s3.console.aws.amazon.com/s3/buckets?region=eu-central-1&bucketType=general&region=eu-central-1|:bucket:*here*>"
    
    message_to_sns = {
        "version": "1.0",
        "source": "custom",
        "content": {
            "description": f" :white_check_mark: CodePipeline Suceeded! \n You can find reports ${buckets_link}!",
        }
    } 
    response = client.publish(TopicArn=sns_topic_arn,MessageStructure='json',Message=json.dumps({'default': json.dumps(message_to_sns)}))
    return response