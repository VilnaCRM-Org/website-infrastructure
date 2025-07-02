#!/usr/bin/env python3
"""
CloudFront Origin Swap Script

Swaps origins between two CloudFront distributions (excluding app distributions).
This is typically used for blue-green deployments.
"""

import json
import logging
import os
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any, Dict, List, Tuple


class CloudFrontOriginSwapError(Exception):
    """CloudFront origin swap operation error"""


class CloudFrontOriginSwapper:
    """Handles CloudFront origin swapping operations"""

    def __init__(self) -> None:
        self.logger = logging.getLogger(self.__class__.__name__)
        self.region = self._get_region()

    def _get_region(self) -> str:
        """Get CloudFront region from environment variable"""
        region = os.environ.get("CLOUDFRONT_REGION")
        if not region:
            raise CloudFrontOriginSwapError("CLOUDFRONT_REGION environment variable is required")
        return region

    def _run_aws_command(self, command: List[str]) -> Dict[str, Any]:
        """Run AWS CLI command and return parsed JSON result"""
        try:
            self.logger.debug("Running: %s", " ".join(command))
            result = subprocess.check_output(command, stderr=subprocess.STDOUT, text=True)
            return json.loads(result)
        except subprocess.CalledProcessError as e:
            raise CloudFrontOriginSwapError(f"AWS CLI failed: {e.output}") from e
        except json.JSONDecodeError as e:
            raise CloudFrontOriginSwapError("Failed to parse AWS CLI response") from e

    def _fetch_distribution_ids(self) -> List[str]:
        """Fetch all CloudFront distribution IDs"""
        self.logger.info("Fetching distribution IDs...")
        
        result = self._run_aws_command([
            "aws", "cloudfront", "list-distributions", 
            "--region", self.region, "--no-cli-pager"
        ])
        
        distribution_ids = [item["Id"] for item in result["DistributionList"]["Items"]]
        self.logger.info("Found %d distributions", len(distribution_ids))
        return distribution_ids

    def _fetch_distribution_config(self, distribution_id: str) -> Dict[str, Any]:
        """Fetch configuration for a single distribution"""
        return self._run_aws_command([
            "aws", "cloudfront", "get-distribution-config",
            "--id", distribution_id, "--region", self.region, "--no-cli-pager"
        ])

    def _should_skip_distribution(self, distribution_id: str, config: Dict[str, Any]) -> bool:
        """Check if distribution should be skipped (has app. prefix)"""
        dist_config = config["DistributionConfig"]
        
        # Check aliases
        aliases = dist_config.get("Aliases", {}).get("Items", [])
        has_app_alias = any(alias.startswith("app.") for alias in aliases)
        
        # Check origins
        origins = dist_config.get("Origins", {}).get("Items", [])
        has_app_origin = any("app." in origin.get("DomainName", "") for origin in origins)
        
        if has_app_alias or has_app_origin:
            self.logger.info("Skipping distribution %s (has app. prefix)", distribution_id)
            return True
        return False

    def _filter_distributions(self) -> Tuple[List[str], List[Dict[str, Any]]]:
        """Fetch and filter distributions, excluding app distributions"""
        self.logger.info("Filtering distributions...")
        
        distribution_ids = self._fetch_distribution_ids()
        filtered_configs, filtered_ids = [], []

        for dist_id in distribution_ids:
            config = self._fetch_distribution_config(dist_id)
            if not self._should_skip_distribution(dist_id, config):
                filtered_configs.append(config)
                filtered_ids.append(dist_id)

        self.logger.info("Filtered to %d distributions", len(filtered_configs))
        
        if len(filtered_configs) != 2:
            raise CloudFrontOriginSwapError(
                f"Expected 2 distributions, found {len(filtered_configs)}. Cannot swap."
            )
        
        return filtered_ids, filtered_configs

    def _swap_origins(self, configs: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Swap origins between two distribution configurations"""
        self.logger.info("Swapping origins...")
        
        if len(configs) != 2:
            raise CloudFrontOriginSwapError("Exactly two configurations required")

        config1, config2 = configs
        origins1 = config1["DistributionConfig"].get("Origins")
        origins2 = config2["DistributionConfig"].get("Origins")

        if origins1 and origins2:
            config1["DistributionConfig"]["Origins"] = origins2
            config2["DistributionConfig"]["Origins"] = origins1

        self.logger.info("Origins swapped successfully")
        return configs

    def _update_distribution(self, distribution_id: str, config: Dict[str, Any]) -> None:
        """Update a single distribution configuration"""
        etag = config["ETag"]
        
        with tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False) as f:
            json.dump(config["DistributionConfig"], f, indent=2)
            temp_path = f.name

        try:
            self._run_aws_command([
                "aws", "cloudfront", "update-distribution",
                "--id", distribution_id, "--distribution-config", f"file://{temp_path}",
                "--region", self.region, "--if-match", etag
            ])
            self.logger.info("Updated distribution %s", distribution_id)
        finally:
            Path(temp_path).unlink(missing_ok=True)

    def execute_origin_swap(self) -> None:
        """Execute the complete origin swap process"""
        self.logger.info("Starting CloudFront origin swap...")
        
        try:
            # Get filtered distributions
            distribution_ids, configs = self._filter_distributions()
            
            # Swap origins
            updated_configs = self._swap_origins(configs)
            
            # Update distributions
            self.logger.info("Updating distributions...")
            for dist_id, config in zip(distribution_ids, updated_configs):
                self._update_distribution(dist_id, config)
            
            self.logger.info("Origin swap completed successfully")
            
        except Exception:
            self.logger.exception("Origin swap failed")
            raise


def setup_logging(level: str = "INFO") -> None:
    """Configure logging"""
    logging.basicConfig(
        level=getattr(logging, level.upper()),
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    )


def main() -> None:
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="CloudFront origin swap for blue-green deployments")
    parser.add_argument("--log-level", choices=["DEBUG", "INFO", "WARNING", "ERROR"], 
                       default="INFO", help="Set logging level")
    
    args = parser.parse_args()
    setup_logging(args.log_level)
    logger = logging.getLogger(__name__)

    try:
        swapper = CloudFrontOriginSwapper()
        swapper.execute_origin_swap()
    except CloudFrontOriginSwapError:
        logger.exception("CloudFront origin swap error")
        sys.exit(1)
    except KeyboardInterrupt:
        logger.warning("Process interrupted")
        sys.exit(130)
    except Exception:
        logger.exception("Unexpected error")
        sys.exit(1)


if __name__ == "__main__":
    main()
