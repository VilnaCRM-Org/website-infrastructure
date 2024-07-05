from dotenv import load_dotenv
import json
import subprocess
import os

# TO DO: Refactor for multiple distributions

CLOUDFRONT_REGION = os.environ['CLOUDFRONT_REGION']

# Load environment variables from .env file
load_dotenv('./.terraform.env')

config_filename = "distribution_config.json"
continuous_deployment_id = os.getenv('CONTINUOUS_DEPLOYMENT_ID')
production_distribution_id = os.getenv('PRODUCTION_DISTRIBUTION_ID')


def fetch_production_distribution_config():
    print("Fetching production distribution configuration...")
    config_result = subprocess.check_output(
        ['aws', 'cloudfront', 'get-distribution-config', '--id',
            production_distribution_id, "--region", CLOUDFRONT_REGION, '--no-cli-pager']
    )
    config_json = json.loads(config_result.decode())
    print(f"Fetched production distribution configuration: {config_json}")
    return config_json


def update_production_distribution_config(config_json):
    print("Updating production distribution configuration...")
    etag = config_json["ETag"]
    config_json['DistributionConfig']["ContinuousDeploymentPolicyId"] = continuous_deployment_id

    with open(config_filename, "w") as text_file:
        text_file.write(json.dumps(config_json['DistributionConfig']))

    subprocess.check_output(
        ['aws', 'cloudfront', 'update-distribution', '--id', production_distribution_id, "--distribution-config",
            f"file://{config_filename}", "--region", CLOUDFRONT_REGION, '--if-match', etag]
    )
    print(
        f"Updated production distribution configuration with ID {production_distribution_id}")


def main():
    print("Starting main function...")
    production_config = fetch_production_distribution_config()
    update_production_distribution_config(production_config)
    print("Main function completed.")


if __name__ == "__main__":
    main()
