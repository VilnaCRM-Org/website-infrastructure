import boto3
import os
import json
import datetime

sns_topic_arn = os.environ["SNS_TOPIC_ARN"]
client = boto3.client('sns')

def lambda_handler(event, context):
    today = datetime.datetime.now()
    in_week = today + datetime.timedelta(days=7)

    data = event
    gh_link = data['github']['gh_link']
    codebuild_link = data['codebuild_link']

    github_commit_author = data['github']['author']
    github_commit_name = data['github']['name']
    github_commit_sha = data['github']['sha']

    codebuild_logs_link = f"<{codebuild_link}|CodeBuild Logs>"
    github_commit_link=f"<{gh_link}|{github_commit_sha[:6]}>"

    data['reports'] = [report for report in data['reports'] if report['name'] or report['link']]

    reports = ""
    for report in data['reports']:
        if report['name'] and report['link']:
            if report['name'] == 'Lighthouse Desktop Reports' or report['name'] == "Lighthouse Mobile Reports":
                name = report['name']
                lighthouse_reports = report['link'].split(";")
                lighthouse_reports = [report.strip() for report in lighthouse_reports if report]
                count = 1
                for report in lighthouse_reports:
                    reports += f"\n(<{report}|[{name}-#{count}]>)"
                    count += 1
            else:
                reports += f"\n[{report['name']}](<{report['link']}|*Link*>)"

    description = f":white_check_mark: Reports Ready! \n Commit info: \n Author: {github_commit_author} \n Name: {github_commit_name} \n SHA: {github_commit_link} \n {codebuild_logs_link} \n Reports: {reports} \n :warning: Reports will be deleted on {in_week.strftime("%m/%d/%Y at %H:%M")}!"

    message_to_sns = {
        "version": "1.0",
        "source": "custom",
        "content": {
            "description": description,
        }
    } 
    response = client.publish(TopicArn=sns_topic_arn,MessageStructure='json',Message=json.dumps({'default': json.dumps(message_to_sns)}))
    return response