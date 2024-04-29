import boto3
import os
import json

sns_topic_arn = os.environ["SNS_TOPIC_ARN"]
client = boto3.client('sns')

def lambda_handler(event, context):
    s3_link = event['s3_link']
    gh_link = event['github']['gh_link']
    codebuild_link = event['codebuild_link']

    github_commit_author = event['github']['author']
    github_commit_name = event['github']['name']
    github_commit_sha = event['github']['sha']

    codebuild_logs_link = f"<{codebuild_link}|*Link*>"
    github_commit_link=f"<{gh_link}|*Link*>"
    buckets_link = f"<{s3_link}|*Link*>"
    
    message_to_sns = {
        "version": "1.0",
        "source": "custom",
        "content": {
            "description": f"Reports Ready! \n Commit info: \n Author: {github_commit_author} \n Name: {github_commit_name} \n SHA: {github_commit_sha} \n {github_commit_link} \n CodeBuild Logs: {codebuild_logs_link} \n Reports: {buckets_link}!",
        }
    } 
    response = client.publish(TopicArn=sns_topic_arn,MessageStructure='json',Message=json.dumps({'default': json.dumps(message_to_sns)}))
    return response