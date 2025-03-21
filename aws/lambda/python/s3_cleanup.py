import json
import boto3

def lambda_handler(event, context):
    bucket_name = event.get("bucket_name")

    if not bucket_name:
        return {"statusCode": 400, "body": json.dumps("Bucket name not provided")}

    s3 = boto3.client("s3")
    events = boto3.client("events")
    lambda_client = boto3.client("lambda")

    try:
        objects = s3.list_objects_v2(Bucket=bucket_name)
        if "Contents" in objects:
            delete_objects = {
                "Objects": [{"Key": obj["Key"]} for obj in objects["Contents"]]
            }
            s3.delete_objects(Bucket=bucket_name, Delete=delete_objects)
        s3.delete_bucket(Bucket=bucket_name)

        rule_name = f"s3-cleanup-{bucket_name}"

        response = events.list_targets_by_rule(Rule=rule_name)
        if response["Targets"]:
            target_id = response["Targets"][0]["Id"]
            events.remove_targets(Rule=rule_name, Ids=[target_id])

        try:
            lambda_policy = lambda_client.get_policy(FunctionName="s3-cleanup-lambda")
            policy_doc = json.loads(lambda_policy["Policy"])

            for statement in policy_doc.get("Statement", []):
                if "Sid" in statement and rule_name in statement["Sid"]:
                    lambda_client.remove_permission(
                        FunctionName="s3-cleanup-lambda",
                        StatementId=statement["Sid"]
                    )
                    print(f"Removed Lambda permission: {statement['Sid']}")

        except lambda_client.exceptions.ResourceNotFoundException:
            print("No existing permissions found. Skipping.")

        events.delete_rule(Name=rule_name)
        print(f"Deleted EventBridge rule: {rule_name}")

        return {
            "statusCode": 200,
            "body": json.dumps(f"Bucket {bucket_name} deleted. EventBridge rule removed.")
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error: {str(e)}")
        }