"""Regression checks for website selection and localized release gates."""

import json
import os
import copy
import unittest
from unittest.mock import patch

import continuous_deployment_switch as policy
import deploy_content
import origin_change
import route_healthcheck


def distribution(identifier, bucket, staging=False):
    return {
        "Id": identifier,
        "Staging": staging,
        "Aliases": {"Items": [] if staging else [bucket]},
        "Origins": {
            "Items": [{"DomainName": f"{bucket}.s3.eu-central-1.amazonaws.com"}]
        },
    }


class BlueGreenTests(unittest.TestCase):
    def test_app_buckets_never_match_website(self):
        items = [
            distribution("website", "vilnacrmtest.com"),
            distribution("website-staging", "staging.vilnacrmtest.com", True),
            distribution("app", "app.vilnacrmtest.com"),
            distribution("app-staging", "staging.app.vilnacrmtest.com", True),
        ]
        with patch.object(
            deploy_content,
            "fetch_distributions",
            return_value={"DistributionList": {"Items": items}},
        ):
            result = deploy_content.find_project_distributions("vilnacrmtest.com")
        self.assertEqual(result["production"]["Id"], "website")
        self.assertEqual(result["staging"]["Id"], "website-staging")

    def test_retry_keeps_staging_header_only(self):
        first = policy.type_handler(
            "SingleWeight", "staging.cloudfront.net", "staging", "0.15"
        )
        retry = policy.type_handler(
            "SingleHeader", "staging.cloudfront.net", "staging", "0.15"
        )
        self.assertEqual(first, retry)
        self.assertEqual(retry["TrafficConfig"]["Type"], "SingleHeader")

    def test_policy_id_is_read_from_primary_config(self):
        primary = distribution("website", "vilnacrmtest.com")
        staging = distribution("website-staging", "staging.vilnacrmtest.com", True)
        staging["DomainName"] = "staging.cloudfront.net"
        config = policy.create_config("staging.cloudfront.net", "staging", "header")
        with patch.dict(
            os.environ,
            {
                "BUCKET_NAME": "vilnacrmtest.com",
                "CLOUDFRONT_REGION": "us-east-1",
                "CLOUDFRONT_HEADER": "staging",
                "CLOUDFRONT_WEIGHT": "0.15",
            },
        ), patch.object(
            policy,
            "find_project_distributions",
            return_value={
                "production": primary,
                "staging": staging,
            },
        ), patch.object(
            policy.subprocess,
            "check_output",
            return_value=json.dumps(
                {
                    "DistributionConfig": {
                        "ContinuousDeploymentPolicyId": "website-policy"
                    },
                }
            ).encode(),
        ) as command, patch.object(
            policy,
            "fetch_continuous_deployment_policy",
            return_value={
                "ETag": "etag",
                "ContinuousDeploymentPolicy": {
                    "ContinuousDeploymentPolicyConfig": config
                },
            },
        ) as fetch, patch.object(
            policy, "update_continuous_deployment_policy"
        ) as update, patch.object(
            policy.subprocess, "check_call"
        ) as wait:
            policy.main()
        self.assertIn("get-distribution-config", command.call_args.args[0])
        self.assertIn("website", command.call_args.args[0])
        fetch.assert_called_once_with("website-policy", "us-east-1")
        update.assert_not_called()
        self.assertEqual(wait.call_count, 2)

    def test_promotion_retries_reconcile_both_sides_without_swapping_back(self):
        blue = distribution("primary", "vilnacrmtest.com")["Origins"]
        green = distribution("staging", "staging.vilnacrmtest.com", True)["Origins"]
        manifest = {
            "target_bucket": "staging.vilnacrmtest.com",
            "origins": {"primary": green, "staging": blue},
        }
        for current, expected_updates in [
            ([blue, green], ["primary", "staging"]),
            ([green, green], ["staging"]),
            ([green, blue], []),
        ]:
            configs = [
                {
                    "ETag": "etag",
                    "DistributionConfig": {"Origins": copy.deepcopy(origins)},
                }
                for origins in current
            ]
            with patch.dict(
                os.environ,
                {
                    "BUCKET_NAME": "vilnacrmtest.com",
                    "CLOUDFRONT_REGION": "us-east-1",
                    "ENABLE_CLOUDFRONT_STAGING": "true",
                },
            ):
                swapper = origin_change.CloudFrontOriginSwapper()
                with patch.object(
                    swapper,
                    "_filter_distributions",
                    return_value=(["primary", "staging"], configs),
                ), patch.object(
                    swapper, "_update_distribution"
                ) as update, patch.object(
                    origin_change.subprocess, "check_call"
                ) as wait:
                    swapper.execute_origin_swap(manifest)
                self.assertEqual(
                    [call.args[0] for call in update.call_args_list], expected_updates
                )
                self.assertEqual(wait.call_count, 2)
                self.assertEqual(configs[0]["DistributionConfig"]["Origins"], green)
                self.assertEqual(configs[1]["DistributionConfig"]["Origins"], blue)

    def test_missing_staging_fails_before_upload(self):
        with patch.dict(
            os.environ, {"ENABLE_CLOUDFRONT_STAGING": "true"}
        ), patch.object(
            deploy_content,
            "find_project_distributions",
            return_value={
                "production": distribution("website", "vilnacrmtest.com"),
                "staging": None,
            },
        ):
            with self.assertRaises(ValueError):
                deploy_content.determine_deployment_target("vilnacrmtest.com")

    def test_deployment_target_alternates_after_promotion(self):
        for active, expected in [
            ("vilnacrmtest.com", "staging.vilnacrmtest.com"),
            ("staging.vilnacrmtest.com", "vilnacrmtest.com"),
        ]:
            with patch.dict(
                os.environ, {"ENABLE_CLOUDFRONT_STAGING": "true"}
            ), patch.object(
                deploy_content,
                "find_project_distributions",
                return_value={
                    "production": distribution("website", active),
                    "staging": distribution("staging", expected, True),
                },
            ):
                self.assertEqual(
                    deploy_content.determine_deployment_target("vilnacrmtest.com"),
                    expected,
                )

    def test_ukrainian_fallback_is_rejected_even_with_http_200(self):
        with patch.object(route_healthcheck, "urlopen") as request:
            response = request.return_value.__enter__.return_value
            response.status = 200
            response.read.return_value = b'<html lang="uk"><script id="__NEXT_DATA__">{"page":"/"}</script></html>'
            with self.assertRaises(RuntimeError):
                route_healthcheck.check("https://example.com/en", {}, "en", "/en")


if __name__ == "__main__":
    unittest.main()
