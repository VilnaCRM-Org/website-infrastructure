import json
import os
import subprocess

from deploy_content import find_project_distributions

MAX_ITEMS = "1"
CONFIG_FILENAME = "continuous_deployment_policy.json"
ENABLE_CLOUDFRONT_STAGING = os.environ.get(
    "ENABLE_CLOUDFRONT_STAGING", ""
).strip().lower() not in {"false", "0", "no"}


def create_config(staging_dns_name, config_value, config_type="weight"):
    print(
        f"Creating config with staging_dns_name: {staging_dns_name}, "
        f"config_value: {config_value}, config_type: {config_type}"
    )
    base_config = {
        "StagingDistributionDnsNames": {"Quantity": 1, "Items": [staging_dns_name]},
        "Enabled": True,
        "TrafficConfig": {
            "Type": "SingleWeight" if config_type == "weight" else "SingleHeader"
        },
    }

    if config_type == "weight":
        base_config["TrafficConfig"]["SingleWeightConfig"] = {
            "Weight": float(config_value)
        }
    elif config_type == "header":
        base_config["TrafficConfig"]["SingleHeaderConfig"] = {
            "Header": f"aws-cf-cd-{config_value}",
            "Value": config_value,
        }

    print(f"Created config: {base_config}")
    return base_config


def type_handler(config_type, staging_dns_name, cloudfront_header, cloudfront_weight):
    print(
        f"Handling type with config_type: {config_type}, "
        f"staging_dns_name: {staging_dns_name}"
    )
    # Retrying a deployment must not send public traffic to the inactive bucket.
    return create_config(staging_dns_name, cloudfront_header, config_type="header")


def fetch_continuous_deployment_policies(cloudfront_region):
    print("Fetching continuous deployment policies")
    result = subprocess.check_output(
        [
            "aws",
            "cloudfront",
            "list-continuous-deployment-policies",
            "--region",
            cloudfront_region,
            "--no-cli-pager",
            "--max-items",
            MAX_ITEMS,
        ]
    )
    policies = json.loads(result.decode())
    print(f"Fetched policies: {policies}")
    return policies


def fetch_continuous_deployment_policy(policy_id, cloudfront_region):
    print(f"Fetching continuous deployment policy with id: {policy_id}")
    result = subprocess.check_output(
        [
            "aws",
            "cloudfront",
            "get-continuous-deployment-policy",
            "--region",
            cloudfront_region,
            "--no-cli-pager",
            "--id",
            policy_id,
        ]
    )
    policy = json.loads(result.decode())
    print(f"Fetched policy: {policy}")
    return policy


def update_continuous_deployment_policy(
    policy_id, policy_etag, config_filename, cloudfront_region
):
    print(
        f"Updating continuous deployment policy with id: {policy_id}, "
        f"etag: {policy_etag}, config_filename: {config_filename}"
    )
    subprocess.check_output(
        [
            "aws",
            "cloudfront",
            "update-continuous-deployment-policy",
            "--id",
            policy_id,
            "--continuous-deployment-policy-config",
            f"file://{config_filename}",
            "--region",
            cloudfront_region,
            "--if-match",
            policy_etag,
        ]
    )
    print(f"Updated policy with id: {policy_id}")


def main():
    print("Starting main function")
    if not ENABLE_CLOUDFRONT_STAGING:
        print("CloudFront staging is disabled, skipping continuous deployment switch")
        return
    required_env = {
        "CLOUDFRONT_WEIGHT": os.environ.get("CLOUDFRONT_WEIGHT"),
        "CLOUDFRONT_HEADER": os.environ.get("CLOUDFRONT_HEADER"),
        "CLOUDFRONT_REGION": os.environ.get("CLOUDFRONT_REGION"),
    }
    missing_env = [name for name, value in required_env.items() if not value]
    if missing_env:
        raise RuntimeError(
            "Missing required environment variables: " + ", ".join(missing_env)
        )

    distributions = find_project_distributions(os.environ["BUCKET_NAME"])
    production = distributions["production"]
    staging = distributions["staging"]
    if not production or not staging:
        raise RuntimeError("Both website distributions are required")
    # ListDistributions omits the policy ID; read the selected primary config.
    production_config = json.loads(
        subprocess.check_output(
            [
                "aws",
                "cloudfront",
                "get-distribution-config",
                "--id",
                production["Id"],
                "--region",
                required_env["CLOUDFRONT_REGION"],
                "--no-cli-pager",
            ]
        )
    )
    policy_item_id = production_config["DistributionConfig"].get(
        "ContinuousDeploymentPolicyId"
    )
    if not policy_item_id:
        raise RuntimeError("Website production distribution has no deployment policy")
    print(f"Policy item id: {policy_item_id}")

    policy = fetch_continuous_deployment_policy(
        policy_item_id, required_env["CLOUDFRONT_REGION"]
    )
    policy_etag = policy["ETag"]
    policy_config = policy["ContinuousDeploymentPolicy"][
        "ContinuousDeploymentPolicyConfig"
    ]
    staging_dns_name = policy_config["StagingDistributionDnsNames"]["Items"][0]
    if staging_dns_name != staging["DomainName"]:
        raise RuntimeError("Deployment policy points to another staging distribution")
    config_type = policy_config["TrafficConfig"]["Type"]
    print(
        f"Policy ETag: {policy_etag}, Staging DNS Name: {staging_dns_name}, "
        f"Config Type: {config_type}"
    )

    continuous_deployment_policy = type_handler(
        config_type,
        staging_dns_name,
        required_env["CLOUDFRONT_HEADER"],
        required_env["CLOUDFRONT_WEIGHT"],
    )

    if policy_config == continuous_deployment_policy:
        print("Website staging policy is already header-only")
    else:
        with open(CONFIG_FILENAME, "w") as config_file:
            print(f"Writing config to {CONFIG_FILENAME}")
            json.dump(continuous_deployment_policy, config_file, indent=4)

        update_continuous_deployment_policy(
            policy_item_id,
            policy_etag,
            CONFIG_FILENAME,
            required_env["CLOUDFRONT_REGION"],
        )
    for distribution in (production, staging):
        subprocess.check_call(
            [
                "aws",
                "cloudfront",
                "wait",
                "distribution-deployed",
                "--id",
                distribution["Id"],
                "--region",
                required_env["CLOUDFRONT_REGION"],
            ]
        )
    print("Main function completed")


if __name__ == "__main__":
    main()
