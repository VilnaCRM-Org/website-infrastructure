"""Regression checks for website selection and localized release gates."""

import os
import unittest
from unittest.mock import patch

import continuous_deployment_switch as policy
import deploy_content
import route_healthcheck


def distribution(identifier, bucket, staging=False):
    return {
        "Id": identifier,
        "Staging": staging,
        "Aliases": {"Items": [] if staging else [bucket]},
        "Origins": {"Items": [{"DomainName": f"{bucket}.s3.eu-central-1.amazonaws.com"}]},
    }


class BlueGreenTests(unittest.TestCase):
    def test_app_buckets_never_match_website(self):
        items = [
            distribution("website", "vilnacrmtest.com"),
            distribution("website-staging", "staging.vilnacrmtest.com", True),
            distribution("app", "app.vilnacrmtest.com"),
            distribution("app-staging", "staging.app.vilnacrmtest.com", True),
        ]
        with patch.object(deploy_content, "fetch_distributions", return_value={"DistributionList": {"Items": items}}):
            result = deploy_content.find_project_distributions("vilnacrmtest.com")
        self.assertEqual(result["production"]["Id"], "website")
        self.assertEqual(result["staging"]["Id"], "website-staging")

    def test_retry_keeps_staging_header_only(self):
        first = policy.type_handler("SingleWeight", "staging.cloudfront.net", "staging", "0.15")
        retry = policy.type_handler("SingleHeader", "staging.cloudfront.net", "staging", "0.15")
        self.assertEqual(first, retry)
        self.assertEqual(retry["TrafficConfig"]["Type"], "SingleHeader")

    def test_missing_staging_fails_before_upload(self):
        with patch.dict(os.environ, {"ENABLE_CLOUDFRONT_STAGING": "true"}), patch.object(
            deploy_content, "find_project_distributions",
            return_value={"production": distribution("website", "vilnacrmtest.com"), "staging": None},
        ):
            with self.assertRaises(ValueError):
                deploy_content.determine_deployment_target("vilnacrmtest.com")

    def test_deployment_target_alternates_after_promotion(self):
        for active, expected in [("vilnacrmtest.com", "staging.vilnacrmtest.com"), ("staging.vilnacrmtest.com", "vilnacrmtest.com")]:
            with patch.dict(os.environ, {"ENABLE_CLOUDFRONT_STAGING": "true"}), patch.object(
                deploy_content, "find_project_distributions",
                return_value={"production": distribution("website", active), "staging": distribution("staging", expected, True)},
            ):
                self.assertEqual(deploy_content.determine_deployment_target("vilnacrmtest.com"), expected)

    def test_ukrainian_fallback_is_rejected_even_with_http_200(self):
        with patch.object(route_healthcheck, "urlopen") as request:
            response = request.return_value.__enter__.return_value
            response.status = 200
            response.read.return_value = b'<html lang="uk"><script id="__NEXT_DATA__">{"page":"/"}</script></html>'
            with self.assertRaises(RuntimeError):
                route_healthcheck.check("https://example.com/en", {}, "en", "/en")


if __name__ == "__main__":
    unittest.main()
