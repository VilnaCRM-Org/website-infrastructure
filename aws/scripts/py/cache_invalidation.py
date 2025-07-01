#!/usr/bin/env python3
"""
CloudFront Cache Invalidation Script

Performs blue-green cache invalidation for CloudFront distributions.
Processes staging distributions first, then production distributions.
"""

import logging
import os
import sys
import time
from enum import Enum
from typing import Any, Optional

import boto3
from botocore.exceptions import ClientError, NoCredentialsError, PartialCredentialsError

try:
    from mypy_boto3_cloudfront import CloudFrontClient
except ImportError:
    CloudFrontClient = Any


class Environment(Enum):
    """Deployment environments"""
    STAGING = "staging"
    PRODUCTION = "production"


class CloudFrontInvalidationError(Exception):
    """CloudFront invalidation operation error"""


class CloudFrontCacheInvalidator:
    """Handles CloudFront cache invalidation operations"""

    def __init__(self):
        self.logger = logging.getLogger(self.__class__.__name__)
        self._client: Optional[CloudFrontClient] = None
        self._load_config_from_environment()

    def _load_config_from_environment(self) -> None:
        """Load configuration from environment variables with sensible defaults"""
        self.timeout_seconds = int(os.getenv('INVALIDATION_TIMEOUT_SECONDS', '900'))
        self.waiter_delay_seconds = int(os.getenv('INVALIDATION_WAITER_DELAY_SECONDS', '10'))
        self.stabilization_wait_seconds = int(os.getenv('INVALIDATION_STABILIZATION_WAIT_SECONDS', '30'))
        self.invalidation_path = os.getenv('INVALIDATION_PATH', '/*')

    @property
    def client(self) -> CloudFrontClient:
        """Get CloudFront client, creating it if needed"""
        if self._client is None:
            self._client = self._create_cloudfront_client()
        return self._client

    def _create_cloudfront_client(self) -> CloudFrontClient:
        """Create and configure CloudFront client"""
        try:
            client = boto3.client("cloudfront")
            self.logger.debug("CloudFront client created successfully")
            return client
        except (NoCredentialsError, PartialCredentialsError) as err:
            raise CloudFrontInvalidationError(
                "AWS credentials not found. Please configure your credentials."
            ) from err
        except Exception as err:
            raise CloudFrontInvalidationError("Failed to create CloudFront client") from err

    def _is_app_distribution(self, origin_domains: list[str]) -> bool:
        """Check if this is an app distribution (should be skipped)"""
        return any("app." in domain for domain in origin_domains)

    def _is_staging_distribution(self, distribution: dict[str, Any], origin_domains: list[str]) -> bool:
        """Check if this is a staging distribution"""
        # Check staging flag
        if distribution.get("IsStagingDistribution", False):
            return True

        # Check for staging in origin domains (but not app domains)
        staging_origins = [
            domain for domain in origin_domains
            if "staging" in domain.lower() and "app." not in domain
        ]
        return len(staging_origins) > 0

    def _classify_distribution(self, distribution: dict[str, Any]) -> Optional[Environment]:
        """Determine if distribution is staging, production, or should be skipped"""
        dist_id = distribution.get('Id', 'Unknown')

        # Skip disabled distributions
        if not distribution.get("Enabled", False):
            self.logger.info("Skipping disabled distribution: %s", dist_id)
            return None

        origin_domains = [
            origin.get("DomainName", "")
            for origin in distribution.get("Origins", {}).get("Items", [])
        ]

        # Skip app distributions
        if self._is_app_distribution(origin_domains):
            self.logger.info("Skipping app distribution: %s", dist_id)
            return None

        # Classify as staging or production
        if self._is_staging_distribution(distribution, origin_domains):
            self.logger.info("Found staging distribution: %s", dist_id)
            return Environment.STAGING

        self.logger.info("Found production distribution: %s", dist_id)
        return Environment.PRODUCTION

    def _fetch_all_distributions(self) -> list[dict[str, Any]]:
        """Fetch all CloudFront distributions from AWS"""
        self.logger.info("Fetching CloudFront distributions...")

        try:
            paginator = self.client.get_paginator("list_distributions")
            all_distributions: list[dict[str, Any]] = []

            for page in paginator.paginate():
                page_distributions = page.get("DistributionList", {}).get("Items", [])
                all_distributions.extend(page_distributions)

            self.logger.info("Retrieved %d total distributions", len(all_distributions))
            return all_distributions

        except ClientError as e:
            error_code = e.response["Error"]["Code"]
            error_message = e.response["Error"]["Message"]
            raise CloudFrontInvalidationError(
                f"Failed to list distributions: {error_code} - {error_message}"
            ) from e

    def find_distributions_by_environment(self) -> dict[Environment, dict[str, Any]]:
        """Find one distribution for each environment (staging and production)"""
        all_distributions = self._fetch_all_distributions()

        env_distributions: dict[Environment, dict[str, Any]] = {}

        # Classify each distribution and keep the first one found for each environment
        for distribution in all_distributions:
            environment = self._classify_distribution(distribution)
            if environment and environment not in env_distributions:
                env_distributions[environment] = distribution

        # Make sure we found both environments
        self._validate_required_environments_found(env_distributions)

        self._log_found_distributions(env_distributions)
        return env_distributions

    def _validate_required_environments_found(self, env_distributions: dict[Environment, dict[str, Any]]) -> None:
        """Ensure we found distributions for all required environments"""
        missing_environments = [env for env in Environment if env not in env_distributions]
        if missing_environments:
            missing_names = [env.value for env in missing_environments]
            raise CloudFrontInvalidationError(
                f"Could not find distributions for: {missing_names}. "
                "Make sure distributions are enabled and properly configured."
            )

    def _log_found_distributions(self, env_distributions: dict[Environment, dict[str, Any]]) -> None:
        """Log the distributions we found for each environment"""
        staging_id = env_distributions[Environment.STAGING]['Id']
        production_id = env_distributions[Environment.PRODUCTION]['Id']
        self.logger.info("Using distributions - Staging: %s, Production: %s", staging_id, production_id)

    def create_invalidation(self, distribution: dict[str, Any], environment: Environment) -> str:
        """Create cache invalidation and return the invalidation ID"""
        dist_id = distribution["Id"]
        self.logger.info("Creating invalidation for %s distribution: %s", environment.value, dist_id)

        invalidation_request = {
            "DistributionId": dist_id,
            "InvalidationBatch": {
                "Paths": {"Quantity": 1, "Items": [self.invalidation_path]},
                "CallerReference": f"blue-green-invalidation-{environment.value}-{int(time.time())}",
            },
        }

        try:
            response = self.client.create_invalidation(**invalidation_request)
            invalidation_id = response["Invalidation"]["Id"]
            self.logger.info("Created invalidation %s for %s", invalidation_id, environment.value)
            return invalidation_id

        except ClientError as e:
            error_code = e.response["Error"]["Code"]
            error_message = e.response["Error"]["Message"]
            raise CloudFrontInvalidationError(
                f"Failed to create invalidation for {environment.value}: {error_code} - {error_message}"
            ) from e

    def wait_for_invalidation(self, distribution: dict[str, Any], invalidation_id: str) -> None:
        """Wait for invalidation to complete"""
        dist_id = distribution["Id"]
        self.logger.info("Waiting for invalidation %s to complete...", invalidation_id)

        max_attempts = self.timeout_seconds // self.waiter_delay_seconds
        waiter_config = {
            "Delay": self.waiter_delay_seconds,
            "MaxAttempts": max_attempts
        }

        try:
            waiter = self.client.get_waiter("invalidation_completed")
            waiter.wait(
                DistributionId=dist_id,
                Id=invalidation_id,
                WaiterConfig=waiter_config
            )
            self.logger.info("Invalidation %s completed successfully", invalidation_id)

        except Exception as err:
            raise CloudFrontInvalidationError(
                f"Invalidation {invalidation_id} failed or timed out after {self.timeout_seconds} seconds"
            ) from err

    def _wait_for_stabilization(self, environment: Environment) -> None:
        """Wait for environment to stabilize before proceeding"""
        if self.stabilization_wait_seconds > 0:
            self.logger.info("Waiting %ds for %s to stabilize...", self.stabilization_wait_seconds, environment.value)
            time.sleep(self.stabilization_wait_seconds)

    def _invalidate_environment(self, distribution: dict[str, Any], environment: Environment) -> None:
        """Invalidate a single environment and wait for completion"""
        self.logger.info("Processing %s environment...", environment.value)

        invalidation_id = self.create_invalidation(distribution, environment)
        self.wait_for_invalidation(distribution, invalidation_id)

        # Only wait for stabilization after staging
        if environment == Environment.STAGING:
            self._wait_for_stabilization(environment)

    def execute_blue_green_invalidation(self) -> None:
        """Execute the complete blue-green cache invalidation process"""
        self.logger.info("Starting blue-green cache invalidation...")

        try:
            # Find the distributions we need
            distributions = self.find_distributions_by_environment()

            # Process staging first, then production
            environments_to_process = [Environment.STAGING, Environment.PRODUCTION]

            for step, environment in enumerate(environments_to_process, 1):
                self.logger.info("Step %d/%d: %s", step, len(environments_to_process), environment.value)
                distribution = distributions[environment]
                self._invalidate_environment(distribution, environment)

            self.logger.info("Blue-green cache invalidation completed successfully")

        except Exception as e:
            self.logger.exception("Cache invalidation failed: %s", e)
            raise


def setup_logging(log_level: str = "INFO") -> None:
    """Configure logging with a clean format"""
    logging.basicConfig(
        level=getattr(logging, log_level.upper()),
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    )


def main() -> None:
    """Run the cache invalidation process"""
    import argparse

    parser = argparse.ArgumentParser(description="CloudFront blue-green cache invalidation")
    parser.add_argument(
        "--log-level",
        choices=["DEBUG", "INFO", "WARNING", "ERROR"],
        default="INFO",
        help="Set the logging level (default: INFO)"
    )

    args = parser.parse_args()
    setup_logging(args.log_level)
    logger = logging.getLogger(__name__)

    try:
        invalidator = CloudFrontCacheInvalidator()
        invalidator.execute_blue_green_invalidation()

    except CloudFrontInvalidationError as e:
        logger.exception("CloudFront invalidation error: %s", e)
        sys.exit(1)
    except KeyboardInterrupt:
        logger.warning("Process interrupted by user")
        sys.exit(130)
    except Exception as e:
        logger.exception("Unexpected error: %s", e)
        sys.exit(1)


if __name__ == "__main__":
    main()
