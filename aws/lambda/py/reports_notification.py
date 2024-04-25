import boto3
import os
import json

sns_topic_arn = os.environ["SNS_TOPIC_ARN"]
client = boto3.client('sns')

def lambda_handler(event, context):
    s3_link = event['link']
    codebuild_build_id = event['codebuild_build_id']
    buckets_link = f"<{s3_link}|:bucket:*here*>"
    
    message_to_sns = {
        "version": "1.0",
        "source": "custom",
        "content": {
            "description": f" :white_check_mark: Reports Ready! \n CodeBuild Build ID: {codebuild_build_id} \n You can find reports {buckets_link}!",
        }
    } 
    response = client.publish(TopicArn=sns_topic_arn,MessageStructure='json',Message=json.dumps({'default': json.dumps(message_to_sns)}))
    return response