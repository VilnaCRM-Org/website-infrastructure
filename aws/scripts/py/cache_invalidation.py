import boto3
import time
from typing import Dict, Any
from botocore.exceptions import ClientError, NoCredentialsError, PartialCredentialsError


def get_cloudfront_client():
    """Get CloudFront client with error handling"""
    try:
        return boto3.client("cloudfront")
    except (NoCredentialsError, PartialCredentialsError) as e:
        raise RuntimeError(f"AWS credentials not found or incomplete: {e}")
    except Exception as e:
        raise RuntimeError(f"Failed to create CloudFront client: {e}")


def get_cloudfront_distributions() -> tuple[Dict[str, Any], Dict[str, Any]]:
    """Get CloudFront distributions and find both staging and production distributions for vilnacrmtest.com"""
    print("Fetching CloudFront distributions...")

    cloudfront = get_cloudfront_client()

    try:
        response = cloudfront.list_distributions()
        distributions = response.get("DistributionList", {}).get("Items", [])
        print("CloudFront distributions fetched.")
    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        error_message = e.response["Error"]["Message"]
        raise RuntimeError(
            f"Failed to list CloudFront distributions: {error_code} - {error_message}"
        )

    staging_origin = "staging.vilnacrmtest.com.s3.eu-central-1.amazonaws.com"
    production_origin = "vilnacrmtest.com.s3.eu-central-1.amazonaws.com"

    staging_dist = None
    production_dist = None

    for dist in distributions:
        for origin in dist.get("Origins", {}).get("Items", []):
            origin_domain = origin.get("DomainName")
            if origin_domain == staging_origin:
                staging_dist = dist
                print(
                    f"Found staging distribution: {dist['Id']} (origin: {origin_domain})"
                )
                break
            elif origin_domain == production_origin:
                production_dist = dist
                print(
                    f"Found production distribution: {dist['Id']} (origin: {origin_domain})"
                )
                break

    if not staging_dist or not production_dist:
        raise RuntimeError(
            "Unable to locate both staging and production CloudFront distributions "
            "for vilnacrmtest.com – check origins or account/region."
        )

    return staging_dist, production_dist


def invalidate_cache(
    distribution: Dict[str, Any], *, is_staging: bool = True
) -> Dict[str, Any]:
    """Create a cache invalidation for the given distribution"""
    env = "staging" if is_staging else "production"
    print(f"Creating invalidation for {env} distribution: {distribution['Id']}")

    cloudfront = get_cloudfront_client()

    try:
        response = cloudfront.create_invalidation(
            DistributionId=distribution["Id"],
            InvalidationBatch={
                "Paths": {"Quantity": 1, "Items": ["/*"]},
                "CallerReference": f"blue-green-invalidation-{env}-{int(time.time())}",
            },
        )
        invalidation = response["Invalidation"]
        print(f"Created invalidation for {env}: {invalidation['Id']}")
        return invalidation
    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        error_message = e.response["Error"]["Message"]
        raise RuntimeError(
            f"Failed to create invalidation for {env}: {error_code} - {error_message}"
        )


def wait_for_invalidation(
    distribution: Dict[str, Any], invalidation_id: str, *, timeout: int = 900
) -> None:
    """Wait for the invalidation to complete"""
    print(f"Waiting for invalidation {invalidation_id} to complete...")

    cloudfront = get_cloudfront_client()

    start = time.time()
    while time.time() - start < timeout:
        try:
            response = cloudfront.get_invalidation(
                DistributionId=distribution["Id"], Id=invalidation_id
            )
            status = response["Invalidation"]["Status"]

            if status == "Completed":
                print(f"Invalidation {invalidation_id} completed")
                return
            elif status == "Failed":
                raise RuntimeError(f"Invalidation {invalidation_id} failed")

            print(f"Invalidation {invalidation_id} status: {status}")
            time.sleep(10)

        except ClientError as e:
            error_code = e.response["Error"]["Code"]
            error_message = e.response["Error"]["Message"]
            raise RuntimeError(
                f"Failed to check invalidation status: {error_code} - {error_message}"
            )

    raise TimeoutError(
        f"Invalidation {invalidation_id} did not complete within {timeout}s"
    )


def main() -> None:
    print("Starting blue-green cache invalidation...")

    try:
        staging_dist, production_dist = get_cloudfront_distributions()

        print("\nStep 1: Invalidating staging distribution...")
        staging_invalidation = invalidate_cache(staging_dist, is_staging=True)
        wait_for_invalidation(staging_dist, staging_invalidation["Id"])

        print("\nStep 2: Waiting for staging to stabilize...")
        time.sleep(30)

        print("\nStep 3: Invalidating production distribution...")
        production_invalidation = invalidate_cache(production_dist, is_staging=False)
        wait_for_invalidation(production_dist, production_invalidation["Id"])

        print("\nBlue-green cache invalidation completed successfully.")

    except Exception as e:
        print(f"\nError during cache invalidation: {e}")
        raise


if __name__ == "__main__":
    main()
