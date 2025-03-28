import json
import boto3
import time


def lambda_handler(event, context):
    bucket_name = event.get("bucket_name")

    if not bucket_name:
        return {"statusCode": 400, "body": json.dumps("Bucket name not provided")}

    s3 = boto3.client("s3")
    events = boto3.client("events")

    try:
        print(f"Listing objects in bucket: {bucket_name}")
        objects = s3.list_objects_v2(Bucket=bucket_name)
        if "Contents" in objects:
            delete_objects = {
                "Objects": [{"Key": obj["Key"]} for obj in objects["Contents"]]
            }
            s3.delete_objects(Bucket=bucket_name, Delete=delete_objects)
            print(f"Deleted objects from {bucket_name}")

        s3.delete_bucket(Bucket=bucket_name)
        print(f"Deleted bucket: {bucket_name}")

        rule_name = f"sandbox-cleanup-{bucket_name}"

        print("Fetching all available rules...")
        rules = events.list_rules()
        found_rule = any(rule["Name"] == rule_name for rule in rules.get("Rules", []))

        if not found_rule:
            print(f"Rule {rule_name} not found in EventBridge!")
            return {
                "statusCode": 404,
                "body": json.dumps(
                    f"Rule {rule_name} not found. Maybe it was already deleted?"
                ),
            }

        print(f"Fetching targets for rule: {rule_name}")
        response = events.list_targets_by_rule(Rule=rule_name)
        targets = response.get("Targets", [])

        if targets:
            target_ids = [target["Id"] for target in targets]
            print(f"Found targets to remove: {target_ids}")

            try:
                events.remove_targets(Rule=rule_name, Ids=target_ids)
                print(f"Removed targets from rule: {rule_name}")

            except Exception as e:
                print(f"Error removing targets from rule: {str(e)}")
                return {
                    "statusCode": 500,
                    "body": json.dumps(f"Error removing targets: {str(e)}"),
                }
        else:
            print(f"No targets found for rule: {rule_name}")

        try:
            print(f"Attempting to delete rule: {rule_name}")
            events.delete_rule(Name=rule_name)
            print(f"Deleted rule: {rule_name}")
        except Exception as e:
            print(f"Error deleting rule: {str(e)}")
            return {
                "statusCode": 500,
                "body": json.dumps(f"Error deleting rule: {str(e)}"),
            }

        return {
            "statusCode": 200,
            "body": json.dumps(
                f"Bucket {bucket_name} deleted. EventBridge rule removed."
            ),
        }

    except Exception as e:
        print(f"General error: {str(e)}")
        return {"statusCode": 500, "body": json.dumps(f"Error: {str(e)}")}
