import boto3
import os
import json

sns_topic_arn = os.environ["SNS_TOPIC_ARN"]
client = boto3.client('sns')

def lambda_handler(event, context):
    
    records = event

    event_source = records['Records'][0]['eventSource']
    event_name = records['Records'][0]['eventName']
    user_identity_id = records['Records'][0]['userIdentity']['principalId']
    bucket_name = records['Records'][0]['s3']['bucket']['name']
    file_name = records['Records'][0]['s3']['object']['key']
    
    warning_string = ":warning: *One of the files were deleted from bucket :bucket:!* \n\n"
    event_source_string = f"*EventSource:* {event_source} \n"
    bucket_name_string = f"*Bucket Name:* {bucket_name} \n"
    file_name_string = f"*File Name:* {file_name} \n"
    user_identity_id_string = f"*User Identity ID:* {user_identity_id}! \n"
    event_name_string = f"*EventName:* {event_name} \n\n"
    buckets_link = "<https://s3.console.aws.amazon.com/s3/buckets?region=eu-central-1&bucketType=general&region=eu-central-1|:bucket:*Buckets*>"
    
    message_to_sns = {
            "version": "1.0",
            "source": "custom",
            "content": {
                "description": f"{warning_string} {event_source_string} {bucket_name_string} {file_name_string} {user_identity_id_string} {event_name_string} {buckets_link}",
        }
    }
    response = client.publish(TopicArn=sns_topic_arn,MessageStructure='json',Message=json.dumps({'default': json.dumps(message_to_sns)}))
    return response
    