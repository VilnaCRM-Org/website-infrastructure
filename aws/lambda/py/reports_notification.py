import boto3
import os
import json
import datetime

sns_topic_arn = os.environ["SNS_TOPIC_ARN"]
client = boto3.client('sns')

def generate_build_succeeding_message(build_succeeding, tests):
    if build_succeeding == "0":
        return f":x: {", ".join(tests)} Failed!"
    else:
        return f":white_check_mark: {", ".join(tests)} Success!"

def generate_reports_messages(reports):
    links = ""
    names = []
    for report in reports:
        names.append(report['name'])
        if len(report['links']) > 1:
            count = 1
            for link in report['links']:
                links += f"\n<{link}|[{report['name']} - #{count}]>"
                count += 1
        else:
            links += f"\n<{report['links'][0]}|[{report['name']}]>"

    return {"names": names, "links": links}

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
    github_commit_link=f"<{gh_link}|{github_commit_sha[:7]}>"

    build_succeeding = data['build_succeeding']

    reports = generate_reports_messages(data["reports"])

    build_succeeding_message = generate_build_succeeding_message(build_succeeding, reports["names"])

    description = f"{build_succeeding_message} \n Commit info: \n Author: {github_commit_author} \n Name: {github_commit_name} \n SHA: {github_commit_link} \n {codebuild_logs_link} \n Reports: {reports["links"]} \n :warning: Reports will be deleted on {in_week.strftime("%m/%d/%Y at %H:%M")}!"

    message_to_sns = {
        "version": "1.0",
        "source": "custom",
        "content": {
            "description": description,
        }
    } 
    response = client.publish(TopicArn=sns_topic_arn,MessageStructure='json',Message=json.dumps({'default': json.dumps(message_to_sns)}))
    return response