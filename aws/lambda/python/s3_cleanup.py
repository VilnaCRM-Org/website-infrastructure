import json
import boto3
import sys
import time

if len(sys.argv) < 2:
    print("Usage: python3 s3_cleanup.py <bucket_name>")
    sys.exit(1)

bucket_name = sys.argv[1]
s3 = boto3.client("s3")

lifecycle_config = {
    "Rules": [
        {
            "ID": "Delete objects after 10 minutes",
            "Status": "Enabled",
            "Expiration": {
                "Days": 1
            },
            "NoncurrentVersionExpiration": {
                "NoncurrentDays": 1
            },
            "AbortIncompleteMultipartUpload": {
                "DaysAfterInitiation": 1
            }
        }
    ]
}

try:
    s3.put_bucket_lifecycle_configuration(
        Bucket=bucket_name,
        LifecycleConfiguration=lifecycle_config
    )
    print(f"Lifecycle policy set for {bucket_name}")
except Exception as e:
    print(f"Error setting lifecycle policy: {e}")

print(f"Waiting 10 minutes before deleting bucket: {bucket_name}...")
time.sleep(600)

try:
    objects = s3.list_objects_v2(Bucket=bucket_name)
    if "Contents" in objects:
        s3.delete_objects(
            Bucket=bucket_name,
            Delete={"Objects": [{"Key": obj["Key"]} for obj in objects["Contents"]]}
        )
    print(f"All objects deleted from {bucket_name}")
except Exception as e:
    print(f"Error deleting objects: {e}")

try:
    s3.delete_bucket(Bucket=bucket_name)
    print(f"Bucket {bucket_name} deleted successfully.")
except Exception as e:
    print(f"Error deleting bucket {bucket_name}: {e}")