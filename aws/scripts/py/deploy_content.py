import json
import subprocess
import os

CLOUDFRONT_REGION = os.environ['CLOUDFRONT_REGION']


def get_buckets():
    print("Getting buckets...")
    return {
        "production": os.environ['BUCKET_NAME'],
        "staging": os.environ['STAGING_BUCKET_NAME'],
    }


def fetch_distributions():
    print("Fetching CloudFront distributions...")
    result = subprocess.check_output(
        ['aws', 'cloudfront', 'list-distributions',
         '--region', CLOUDFRONT_REGION, '--no-cli-pager',]
    )
    distributions = json.loads(result.decode())
    print(f"Fetched distributions: {distributions}")
    return distributions


def get_staging_distribution(distributions):
    print("Finding staging distribution...")
    for item in distributions["DistributionList"]["Items"]:
        if item["Staging"] == True:
            print(f"Staging distribution found: {item}")
            return item


def get_origins(distribution):
    print("Fetching origins...")
    return distribution["Origins"]["Items"]


def check_origins(origins):
    print("Checking origins...")
    if origins[0]["DomainName"].startswith("staging"):
        print("Origins belong to staging environment.")
        return True
    print("Origins belong to production environment.")
    return False


def deploy_files(bucket_name):
    print(f"Deploying files to bucket: {bucket_name}")
    return subprocess.check_output(['aws', 's3', 'sync', './out', f's3://{bucket_name}'])


def main():
    print("Starting main function...")
    buckets = get_buckets()
    print(f"Buckets: {buckets}")

    cloudfront_distributions = fetch_distributions()
    print("CloudFront distributions fetched.")

    staging_distribution = get_staging_distribution(cloudfront_distributions)
    if staging_distribution:
        print(f"Staging distribution: {staging_distribution}")

    if staging_distribution:
        origins = get_origins(staging_distribution)
        if origins:
            print(f"Origins: {origins}")
            if check_origins(origins):
                deploy_files(buckets["staging"])
                print("Files deployed to staging bucket.")
                return

    deploy_files(buckets["production"])
    print("Files deployed to production bucket.")

    print("Main function completed.")


if __name__ == "__main__":
    main()
