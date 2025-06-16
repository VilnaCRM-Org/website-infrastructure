import json
import subprocess
import os
import time

def get_cloudfront_distributions():
    """Get CloudFront distributions and find both staging and production distributions for vilnacrmtest.com"""
    print("Fetching CloudFront distributions...")
    result = subprocess.run(
        ["aws", "cloudfront", "list-distributions"],
        capture_output=True,
        text=True
    )
    distributions = json.loads(result.stdout)
    print("CloudFront distributions fetched.")

    target_origins = [
        "staging.vilnacrmtest.com.s3.eu-central-1.amazonaws.com",
        "vilnacrmtest.com.s3.eu-central-1.amazonaws.com"
    ]

    staging_dist = None
    production_dist = None

    for dist in distributions.get("DistributionList", {}).get("Items", []):
        for origin in dist.get("Origins", {}).get("Items", []):
            if origin.get("DomainName") in target_origins:
                if dist.get("Staging", False):
                    staging_dist = dist
                    print(f"Found staging distribution: {dist['Id']}")
                else:
                    production_dist = dist
                    print(f"Found production distribution: {dist['Id']}")
                break

    if not staging_dist or not production_dist:
        raise Exception("Could not find both staging and production distributions for vilnacrmtest.com")
    
    return staging_dist, production_dist

def invalidate_cache(distribution, is_staging=True):
    """Create a cache invalidation for the given distribution"""
    env = "staging" if is_staging else "production"
    print(f"Creating invalidation for {env} distribution: {distribution['Id']}")
    result = subprocess.run(
        [
            "aws", "cloudfront", "create-invalidation",
            "--distribution-id", distribution["Id"],
            "--paths", "/*"
        ],
        capture_output=True,
        text=True
    )
    invalidation = json.loads(result.stdout)
    print(f"Created invalidation for {env}: {invalidation['Invalidation']['Id']}")
    return invalidation

def wait_for_invalidation(distribution, invalidation_id):
    """Wait for the invalidation to complete"""
    print(f"Waiting for invalidation {invalidation_id} to complete...")
    while True:
        result = subprocess.run(
            [
                "aws", "cloudfront", "get-invalidation",
                "--distribution-id", distribution["Id"],
                "--id", invalidation_id
            ],
            capture_output=True,
            text=True
        )
        status = json.loads(result.stdout)["Invalidation"]["Status"]
        if status == "Completed":
            print(f"Invalidation {invalidation_id} completed")
            break
        print(f"Invalidation {invalidation_id} status: {status}")
        time.sleep(10)  # Wait 10 seconds before checking again

def main():
    print("Starting blue-green cache invalidation...")

    staging_dist, production_dist = get_cloudfront_distributions()

    print("\nStep 1: Invalidating staging distribution...")
    staging_invalidation = invalidate_cache(staging_dist, is_staging=True)
    wait_for_invalidation(staging_dist, staging_invalidation["Invalidation"]["Id"])

    print("\nStep 2: Waiting for staging to stabilize...")
    time.sleep(30)  # Wait 30 seconds

    print("\nStep 3: Invalidating production distribution...")
    production_invalidation = invalidate_cache(production_dist, is_staging=False)
    wait_for_invalidation(production_dist, production_invalidation["Invalidation"]["Id"])
    
    print("\nBlue-green cache invalidation completed successfully.")

if __name__ == "__main__":
    main() 