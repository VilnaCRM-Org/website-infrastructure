import json
import boto3


def lambda_handler(event):
    bucket_name = event.get("bucket_name")

    if not bucket_name:
        return {"statusCode": 400, "body": json.dumps("Bucket name not provided")}

    s3 = boto3.client("s3")
    events = boto3.client("events")

    try:
        objects = s3.list_objects_v2(Bucket=bucket_name)

        if "Contents" in objects:
            delete_objects = {
                "Objects": [{"Key": obj["Key"]} for obj in objects["Contents"]]
            }
            s3.delete_objects(Bucket=bucket_name, Delete=delete_objects)

        s3.delete_bucket(Bucket=bucket_name)

        rule_name = f"s3-cleanup-{bucket_name}"
        events.remove_targets(Rule=rule_name, Ids=["1"])
        events.delete_rule(Name=rule_name)

        return {
            "statusCode": 200,
            "body": json.dumps(
                f"Bucket {bucket_name} and all its objects deleted successfully. EventBridge rule removed."
            ),
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error deleting bucket, objects, or rule: {str(e)}"),
        }
