import json
import subprocess
import os

MAX_ITEMS = "1"
CONFIG_FILENAME = "continuous_deployment_policy.json"

CLOUDFRONT_WEIGHT = os.environ['CLOUDFRONT_WEIGHT']
CLOUDFRONT_HEADER = os.environ['CLOUDFRONT_HEADER']
CLOUDFRONT_REGION = os.environ['CLOUDFRONT_REGION']


def create_config(staging_dns_name, config_value, config_type='weight'):
    print(
        f"Creating config with staging_dns_name: {staging_dns_name}, config_value: {config_value}, config_type: {config_type}")
    base_config = {
        "StagingDistributionDnsNames": {
            "Quantity": 1,
            "Items": [staging_dns_name]
        },
        "Enabled": True,
        "TrafficConfig": {
            "Type": "SingleWeight" if config_type == 'weight' else "SingleHeader"
        }
    }

    if config_type == 'weight':
        base_config["TrafficConfig"]["SingleWeightConfig"] = {
            "Weight": float(config_value)
        }
    elif config_type == 'header':
        base_config["TrafficConfig"]["SingleHeaderConfig"] = {
            "Header": f"aws-cf-cd-{config_value}",
            "Value": config_value
        }

    print(f"Created config: {base_config}")
    return base_config


def type_handler(config_type, staging_dns_name):
    print(
        f"Handling type with config_type: {config_type}, staging_dns_name: {staging_dns_name}")
    if config_type != "SingleHeader":
        return create_config(staging_dns_name, CLOUDFRONT_HEADER, config_type='header')
    return create_config(staging_dns_name, CLOUDFRONT_WEIGHT, config_type='weight')


def fetch_continuous_deployment_policies():
    print("Fetching continuous deployment policies")
    result = subprocess.check_output(
        ['aws', 'cloudfront', 'list-continuous-deployment-policies',
         '--region', CLOUDFRONT_REGION, '--no-cli-pager', '--max-items', MAX_ITEMS]
    )
    policies = json.loads(result.decode())
    print(f"Fetched policies: {policies}")
    return policies


def fetch_continuous_deployment_policy(id):
    print(f"Fetching continuous deployment policy with id: {id}")
    result = subprocess.check_output(
        ['aws', 'cloudfront', 'get-continuous-deployment-policy',
         '--region', CLOUDFRONT_REGION, '--no-cli-pager', '--id', id]
    )
    policy = json.loads(result.decode())
    print(f"Fetched policy: {policy}")
    return policy


def update_continuous_deployment_policy(policy_id, policy_etag, config_filename):
    print(
        f"Updating continuous deployment policy with id: {policy_id}, etag: {policy_etag}, config_filename: {config_filename}")
    subprocess.check_output(
        ['aws', 'cloudfront', 'update-continuous-deployment-policy',
         '--id', policy_id, '--continuous-deployment-policy-config',
         f"file://{config_filename}", '--region', CLOUDFRONT_REGION, '--if-match', policy_etag]
    )
    print(f"Updated policy with id: {policy_id}")


def main():
    print("Starting main function")
    policies_list = fetch_continuous_deployment_policies()
    policy_item = policies_list["ContinuousDeploymentPolicyList"]["Items"][0]["ContinuousDeploymentPolicy"]
    policy_item_id = policy_item["Id"]
    print(f"Policy item id: {policy_item_id}")

    policy = fetch_continuous_deployment_policy(policy_item_id)
    policy_etag = policy["ETag"]
    policy_config = policy["ContinuousDeploymentPolicy"]["ContinuousDeploymentPolicyConfig"]
    staging_dns_name = policy_config["StagingDistributionDnsNames"]["Items"][0]
    config_type = policy_config["TrafficConfig"]["Type"]
    print(
        f"Policy ETag: {policy_etag}, Staging DNS Name: {staging_dns_name}, Config Type: {config_type}")

    continuous_deployment_policy = type_handler(config_type, staging_dns_name)

    with open(CONFIG_FILENAME, "w") as config_file:
        print(f"Writing config to {CONFIG_FILENAME}")
        json.dump(continuous_deployment_policy, config_file, indent=4)

    update_continuous_deployment_policy(
        policy_item_id, policy_etag, CONFIG_FILENAME)
    print("Main function completed")


if __name__ == "__main__":
    main()
