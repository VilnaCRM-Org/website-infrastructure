import json
import subprocess

# Configuration constants
MAX_ITEMS = "1"
WEIGHT = 0.15
HEADER = "staging"
CONFIG_FILENAME = "continuous_deployment_policy.json"
REGION = 'us-east-1'


def create_config(staging_dns_name, config_value, config_type='weight'):
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
            "Weight": config_value
        }
    elif config_type == 'header':
        base_config["TrafficConfig"]["SingleHeaderConfig"] = {
            "Header": f"aws-cf-cd-{config_value}",
            "Value": config_value
        }

    return base_config


def type_handler(config_type, staging_dns_name):
    if config_type != "SingleHeader":
        return create_config(staging_dns_name, HEADER, config_type='header')
    return create_config(staging_dns_name, WEIGHT, config_type='weight')


def fetch_continuous_deployment_policies():
    result = subprocess.check_output(
        ['aws', 'cloudfront', 'list-continuous-deployment-policies',
         '--region', REGION, '--no-cli-pager', '--max-items', MAX_ITEMS]
    )
    return json.loads(result.decode())


def fetch_continuous_deployment_policy(id):
    result = subprocess.check_output(
        ['aws', 'cloudfront', 'get-continuous-deployment-policy',
         '--region', REGION, '--no-cli-pager', '--id', id]
    )
    return json.loads(result.decode())


def update_continuous_deployment_policy(policy_id, policy_etag, config_filename):
    subprocess.check_output(
        ['aws', 'cloudfront', 'update-continuous-deployment-policy',
         '--id', policy_id, '--continuous-deployment-policy-config',
         f"file://{config_filename}", '--region', REGION, '--if-match', policy_etag]
    )


def main():
    policies_list = fetch_continuous_deployment_policies()
    policy_item = policies_list["ContinuousDeploymentPolicyList"]["Items"][0]["ContinuousDeploymentPolicy"]
    policy_item_id = policy_item["Id"]
    policy = fetch_continuous_deployment_policy(policy_item_id)
    policy_etag = policy["ETag"]
    policy_config = policy["ContinuousDeploymentPolicy"]["ContinuousDeploymentPolicyConfig"]
    staging_dns_name = policy_config["StagingDistributionDnsNames"]["Items"][0]
    config_type = policy_config["TrafficConfig"]["Type"]

    continuous_deployment_policy = type_handler(config_type, staging_dns_name)

    with open(CONFIG_FILENAME, "w") as config_file:
        json.dump(continuous_deployment_policy, config_file, indent=4)

    update_continuous_deployment_policy(
        policy_item_id, policy_etag, CONFIG_FILENAME)


if __name__ == "__main__":
    main()
