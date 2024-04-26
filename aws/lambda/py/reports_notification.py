import boto3
import os
import json

sns_topic_arn = os.environ["SNS_TOPIC_ARN"]
client = boto3.client('sns')

def lambda_handler(event, context):
    s3_link = event['s3_link']
    gh_link = event['gh_link']
    codebuild_link = event['codebuild_link']

    codebuild_logs_link = f"<{codebuild_link}|*here*>"
    github_commit_link=f"<{gh_link}|*here*>"
    buckets_link = f"<{s3_link}|*here*>"
    
    message_to_sns = {
        "version": "1.0",
        "source": "custom",
        "content": {
            "description": f" :white_check_mark: Reports Ready! \n Commit: {github_commit_link} \n CodeBuild Logs: {codebuild_logs_link} \n Reports: {buckets_link}!",
        }
    } 
    response = client.publish(TopicArn=sns_topic_arn,MessageStructure='json',Message=json.dumps({'default': json.dumps(message_to_sns)}))
    return response