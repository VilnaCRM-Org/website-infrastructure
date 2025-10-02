import json
import subprocess
import os

CLOUDFRONT_REGION = os.environ["CLOUDFRONT_REGION"]


def get_bucket():
    print("Getting bucket...")
    return os.environ["BUCKET_NAME"]


def fetch_distributions():
    print("Fetching CloudFront distributions...")
    result = subprocess.check_output(
        [
            "aws",
            "cloudfront",
            "list-distributions",
            "--region",
            CLOUDFRONT_REGION,
            "--no-cli-pager",
        ]
    )
    distributions = json.loads(result.decode())
    print(f"Fetched distributions: {distributions}")
    return distributions


def get_staging_distribution(distributions):
    print("Finding staging distribution...")
    for item in distributions["DistributionList"]["Items"]:
        if item["Staging"]:
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


def deploy_files(target_bucket):
    print(f"Deploying files to target bucket: {target_bucket}")
    try:
        result = subprocess.check_output(
            ["aws", "s3", "sync", "./out", f"s3://{target_bucket}"]
        )
        print(f"Successfully deployed to bucket: {target_bucket}")
        return result
    except subprocess.CalledProcessError as e:
        print(f"Error deploying to bucket {target_bucket}: {e}")
        raise


def determine_deployment_target(bucket_name):
    """
    Determine which bucket to deploy to based on current production setup.
    Deploy to the environment that is NOT currently serving production traffic.
    """
    print("Determining deployment target for blue-green deployment...")

    cloudfront_distributions = fetch_distributions()

    # Find production distribution (the one with aliases)
    production_distribution = None
    for dist in cloudfront_distributions["DistributionList"]["Items"]:
        if dist.get("Aliases", {}).get("Quantity", 0) > 0:
            # This is the production distribution
            production_distribution = dist
            break

    if not production_distribution:
        print("Could not find production distribution, defaulting to staging bucket")
        return f"staging.{bucket_name}"

    # Check which bucket production is currently pointing to
    origins = production_distribution["Origins"]["Items"]
    current_prod_origin = origins[0]["DomainName"]

    print(f"Production currently points to: {current_prod_origin}")

    if "staging." in current_prod_origin:
        # Production is on Green (staging bucket), deploy to Blue (main bucket)
        target_bucket = bucket_name
        environment = "Blue"
    else:
        # Production is on Blue (main bucket), deploy to Green (staging bucket)
        target_bucket = f"staging.{bucket_name}"
        environment = "Green"

    print(f"Deploying to {environment} environment: {target_bucket}")
    return target_bucket


def main():
    print("Starting blue-green deployment...")
    bucket_name = get_bucket()
    print(f"Base bucket name: {bucket_name}")

    # Determine which environment to deploy to (the non-production one)
    target_bucket = determine_deployment_target(bucket_name)

    # Deploy to the target environment only
    deploy_files(target_bucket)
    print(f"Blue-green deployment completed. New version deployed to: {target_bucket}")
    print("Use the release pipeline to promote this version to production.")

    print("Main function completed.")


if __name__ == "__main__":
    main()
