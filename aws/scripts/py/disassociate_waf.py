import json
import os
import subprocess
import tempfile
import time

CLOUDFRONT_REGION = os.environ["CLOUDFRONT_REGION"]
BUCKET_NAME = os.environ["BUCKET_NAME"]


def run_aws(command):
    return subprocess.check_output(
        ["aws", *command, "--region", CLOUDFRONT_REGION, "--no-cli-pager"],
        text=True,
    )


def fetch_distributions():
    return json.loads(run_aws(["cloudfront", "list-distributions"]))


def matches_origin(bucket_name, origin_domain):
    valid_prefixes = {
        f"{bucket_name}.s3.",
        f"{bucket_name}-replication.s3.",
        f"staging.{bucket_name}.s3.",
        f"staging.{bucket_name}-replication.s3.",
    }
    return any(origin_domain.startswith(prefix) for prefix in valid_prefixes)


def find_project_distributions(bucket_name):
    cloudfront_distributions = fetch_distributions()
    project_distribution_ids = set()
    project_distributions = []

    for dist in cloudfront_distributions.get("DistributionList", {}).get("Items", []):
        aliases = dist.get("Aliases", {}).get("Items") or []
        origins = dist.get("Origins", {}).get("Items", [])

        is_our_project = any(
            alias in {bucket_name, f"www.{bucket_name}"} for alias in aliases
        )

        if not is_our_project:
            for origin in origins:
                origin_domain = origin.get("DomainName", "")
                if matches_origin(bucket_name, origin_domain):
                    is_our_project = True
                    break

        if not is_our_project:
            continue

        distribution_id = dist["Id"]
        if distribution_id in project_distribution_ids:
            continue

        project_distribution_ids.add(distribution_id)
        project_distributions.append(dist)

    return sorted(
        project_distributions,
        key=lambda dist: not bool(dist.get("Aliases", {}).get("Items") or []),
    )


def fetch_distribution_config(distribution_id):
    return json.loads(
        run_aws(["cloudfront", "get-distribution-config", "--id", distribution_id])
    )


def update_distribution_config(distribution_id, config_json):
    with tempfile.NamedTemporaryFile(mode="w", delete=False) as temp_file:
        json.dump(config_json["DistributionConfig"], temp_file)
        temp_path = temp_file.name

    try:
        subprocess.check_call(
            [
                "aws",
                "cloudfront",
                "update-distribution",
                "--id",
                distribution_id,
                "--distribution-config",
                f"file://{temp_path}",
                "--if-match",
                config_json["ETag"],
                "--region",
                CLOUDFRONT_REGION,
                "--no-cli-pager",
            ]
        )
    finally:
        os.unlink(temp_path)


def wait_for_distribution(distribution_id, timeout_seconds=900, sleep_seconds=15):
    deadline = time.time() + timeout_seconds
    while time.time() < deadline:
        response = json.loads(
            run_aws(["cloudfront", "get-distribution", "--id", distribution_id])
        )
        distribution = response["Distribution"]
        status = distribution["Status"]
        policy_id = distribution["DistributionConfig"].get(
            "ContinuousDeploymentPolicyId", ""
        )
        if status == "Deployed" and not policy_id:
            return
        time.sleep(sleep_seconds)
    raise TimeoutError(
        "Timed out waiting for CloudFront distribution "
        f"{distribution_id} to clear the continuous deployment policy"
    )


def prepare_distribution(distribution):
    distribution_id = distribution["Id"]
    config_json = fetch_distribution_config(distribution_id)
    policy_id = config_json["DistributionConfig"].get(
        "ContinuousDeploymentPolicyId", ""
    )
    aliases = config_json["DistributionConfig"].get("Aliases", {}).get("Items") or []

    if not policy_id:
        print(
            f"Distribution {distribution_id} already has no continuous deployment policy"
        )
        return

    if not aliases:
        print(
            f"Distribution {distribution_id} is a staging distribution; "
            "waiting for the primary distribution to detach the continuous "
            "deployment policy"
        )
        wait_for_distribution(distribution_id)
        print(
            "Distribution "
            f"{distribution_id} continuous deployment policy association cleared"
        )
        return

    print(
        "Clearing continuous deployment policy "
        f"for distribution {distribution_id}: {policy_id}"
    )
    config_json["DistributionConfig"]["ContinuousDeploymentPolicyId"] = ""
    update_distribution_config(distribution_id, config_json)
    wait_for_distribution(distribution_id)
    print(
        f"Distribution {distribution_id} continuous deployment policy association cleared"
    )


def main():
    distributions = find_project_distributions(BUCKET_NAME)
    if not distributions:
        raise RuntimeError(
            f"No CloudFront distributions found for bucket {BUCKET_NAME}"
        )

    for distribution in distributions:
        prepare_distribution(distribution)


if __name__ == "__main__":
    main()
