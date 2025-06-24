import boto3
import time
from enum import Enum
from typing import Dict, Any, List
from botocore.exceptions import ClientError, NoCredentialsError, PartialCredentialsError

try:
    from mypy_boto3_cloudfront import CloudFrontClient
except ImportError:
    CloudFrontClient = Any


class Environment(Enum):
    STAGING = "staging"
    PRODUCTION = "production"


def get_cloudfront_client() -> CloudFrontClient:
    """Get CloudFront client with error handling"""
    try:
        return boto3.client("cloudfront")
    except (NoCredentialsError, PartialCredentialsError) as err:
        raise RuntimeError("AWS credentials not found or incomplete") from err
    except Exception as err:
        raise RuntimeError("Failed to create CloudFront client") from err


def classify_distribution(dist: Dict[str, Any]) -> Environment | None:
    """Classify a distribution as staging, production, or None (skip)"""
    if not dist.get("Enabled", False):
        print(f"Skipping disabled distribution: {dist['Id']}")
        return None

    origin_domains = [
        origin.get("DomainName", "")
        for origin in dist.get("Origins", {}).get("Items", [])
    ]

    # Skip app distributions
    if any("app." in domain for domain in origin_domains):
        print(f"Skipping app distribution: {dist['Id']} (origins: {origin_domains})")
        return None

    # Check for staging indicators
    is_staging_dist = dist.get("IsStagingDistribution", False)
    has_staging_origin = any(
        "staging" in domain.lower() and "app." not in domain
        for domain in origin_domains
    )
    
    if is_staging_dist or has_staging_origin:
        print(f"Found staging distribution: {dist['Id']} (origins: {origin_domains})")
        return Environment.STAGING
    
    print(f"Found production distribution: {dist['Id']} (origins: {origin_domains})")
    return Environment.PRODUCTION


def get_distributions_by_environment() -> Dict[Environment, Dict[str, Any]]:
    """Get CloudFront distributions mapped by environment"""
    print("Fetching CloudFront distributions...")

    cloudfront = get_cloudfront_client()

    try:
        paginator = cloudfront.get_paginator("list_distributions")
        distributions: List[Dict] = []
        for page in paginator.paginate():
            distributions.extend(page.get("DistributionList", {}).get("Items", []))
        print(f"Found {len(distributions)} total distributions.")
    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        error_message = e.response["Error"]["Message"]
        raise RuntimeError(
            f"Failed to list CloudFront distributions: {error_code} - {error_message}"
        )

    env_distributions = {}
    
    for dist in distributions:
        env = classify_distribution(dist)
        if env and env not in env_distributions:
            env_distributions[env] = dist

    # Verify we found both environments
    for env in Environment:
        if env not in env_distributions:
            raise RuntimeError(
                f"Unable to locate {env.value} CloudFront distribution. "
                "Ensure the distribution is enabled and properly configured."
            )

    print(f"Found distributions - Staging: {env_distributions[Environment.STAGING]['Id']}, "
          f"Production: {env_distributions[Environment.PRODUCTION]['Id']}")
    
    return env_distributions


def invalidate_cache(distribution: Dict[str, Any], env: Environment) -> Dict[str, Any]:
    """Create a cache invalidation for the given distribution"""
    print(f"Creating invalidation for {env.value} distribution: {distribution['Id']}")

    cloudfront = get_cloudfront_client()

    try:
        response = cloudfront.create_invalidation(
            DistributionId=distribution["Id"],
            InvalidationBatch={
                "Paths": {"Quantity": 1, "Items": ["/*"]},
                "CallerReference": f"blue-green-invalidation-{env.value}-{int(time.time())}",
            },
        )
        invalidation = response["Invalidation"]
        print(f"Created invalidation for {env.value}: {invalidation['Id']}")
        return invalidation
    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        error_message = e.response["Error"]["Message"]
        raise RuntimeError(
            f"Failed to create invalidation for {env.value}: {error_code} - {error_message}"
        )


def wait_for_invalidation(
    distribution: Dict[str, Any], invalidation_id: str, *, timeout: int = 900
) -> None:
    """Wait for the invalidation to complete"""
    print(f"Waiting for invalidation {invalidation_id} to complete...")

    try:
        client = get_cloudfront_client()
        waiter = client.get_waiter("invalidation_completed")
        waiter.wait(
            DistributionId=distribution["Id"],
            Id=invalidation_id,
            WaiterConfig={"Delay": 10, "MaxAttempts": timeout // 10},
        )
        print(f"Invalidation {invalidation_id} completed")
    except Exception as err:
        raise RuntimeError(
            f"Invalidation {invalidation_id} failed or timed out"
        ) from err


def main() -> None:
    """Execute blue-green cache invalidation"""
    print("Starting blue-green cache invalidation...")

    try:
        distributions = get_distributions_by_environment()
        
        # Process environments in order: staging first, then production
        environments = [Environment.STAGING, Environment.PRODUCTION]
        
        for step, env in enumerate(environments, 1):
            dist = distributions[env]
            print(f"\nStep {step}: Invalidating {env.value} distribution...")
            invalidation = invalidate_cache(dist, env)
            wait_for_invalidation(dist, invalidation["Id"])
            
            # Add stabilization wait between environments
            if env == Environment.STAGING:
                print(f"\nWaiting for {env.value} to stabilize...")
                time.sleep(30)

        print("\nBlue-green cache invalidation completed successfully.")

    except Exception as e:
        print(f"\nError during cache invalidation: {e}")
        raise


if __name__ == "__main__":
    main()
