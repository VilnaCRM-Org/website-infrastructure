import boto3
import os
import json

sns_topic_arn = os.environ["SNS_TOPIC_ARN"]
client = boto3.client('sns')


def lambda_handler(event, context):

    records = event['Records'][0]

    event_name = records['eventName']
    event_source = records['eventSource']
    user_identity_id = records['userIdentity']['principalId']
    bucket_name = records['s3']['bucket']['name']
    file_name = records['s3']['object']['key']

    event_source_string = f"*EventSource:* {event_source} \n"
    bucket_name_string = f"*Bucket Name:* {bucket_name} \n"
    file_name_string = f"*File Name:* {file_name} \n"
    user_identity_id_string = f"*User Identity ID:* {user_identity_id}! \n"
    event_name_string = f"*EventName:* {event_name} \n\n"
    buckets_link = (
        "<https://s3.console.aws.amazon.com/s3/buckets?region=eu-central-1&bucketType=general&region=eu-central-1|"
        ":bucket:*Buckets*>"
    )

    event_core = event_name.split(":")

    if event_core[0] == "ObjectRemoved":
        warning_string = ":x: *One of the files were deleted from the bucket :bucket:!* \n\n"
    else:
        warning_string = ":warning: *One of the file`s ACL were modified :bucket:!* \n\n"

    try:
        message_to_sns = {
            "version": "1.0",
            "source": "custom",
            "content": {
                "description": (
                    f"{warning_string} {event_source_string} {bucket_name_string} {file_name_string} "
                    f"{user_identity_id_string} {event_name_string} {buckets_link}"
                ),
            },
        }

        response = client.publish(
            TopicArn=sns_topic_arn,
            MessageStructure='json',
            Message=json.dumps({'default': json.dumps(message_to_sns)}),
        )
        print(f"Successfully published message: {response['MessageId']}")
        return response
    except client.exceptions.InvalidParameterException as e:
        print(f"Invalid parameter in SNS publish: {e}")
        raise
    except client.exceptions.InvalidMessageStructureException as e:
        print(f"Invalid message structure: {e}")
        raise
    except Exception as e:
        print(f"Error publishing to SNS: {e}")
        raise