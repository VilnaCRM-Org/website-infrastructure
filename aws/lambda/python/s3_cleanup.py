import boto3
import sys


def delete_s3_bucket(bucket_name):
    s3 = boto3.client("s3")
    try:
        print(f"Deleting all objects in bucket: {bucket_name}")
        objects = s3.list_objects_v2(Bucket=bucket_name)
        if "Contents" in objects:
            for obj in objects["Contents"]:
                s3.delete_object(Bucket=bucket_name, Key=obj["Key"])

        print(f"Deleting bucket: {bucket_name}")
        s3.delete_bucket(Bucket=bucket_name)
        print(f"Bucket {bucket_name} deleted successfully.")
    except Exception as e:
        print(f"Error deleting bucket {bucket_name}: {str(e)}")


def lambda_handler(event, context):
    bucket_name = event.get("detail", {}).get("bucket_name")

    if not bucket_name:
        print("Error: No bucket name provided in the event")
        return

    print(f"Received bucket name: {bucket_name}")
    delete_s3_bucket(bucket_name)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 s3_cleanup.py <bucket_name>")
        sys.exit(1)

    bucket_name = sys.argv[1]
    delete_s3_bucket(bucket_name)
