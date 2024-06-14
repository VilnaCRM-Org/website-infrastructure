from dotenv import load_dotenv
import json
import subprocess
import os

CLOUDFRONT_REGION = os.environ['CLOUDFRONT_REGION']

# Load environment variables from .env file
load_dotenv('./.terraform.env')

config_filename = "distribution_config.json"
continuous_deployment_id = os.getenv('CONTINUOUS_DEPLOYMENT_ID')
production_distribution_id = os.getenv('PRODUCTION_DISTRIBUTION_ID')

config = subprocess.check_output(
    ['aws', 'cloudfront', 'get-distribution-config', '--id', production_distribution_id, "--region", CLOUDFRONT_REGION, '--no-cli-pager'])

config_json = json.loads(config.decode())

etag = config_json["ETag"]

config_json['DistributionConfig']["ContinuousDeploymentPolicyId"] = continuous_deployment_id

with open(config_filename, "w") as text_file:
    text_file.write(json.dumps(config_json['DistributionConfig']))

subprocess.check_output(
    ['aws', 'cloudfront', 'update-distribution', '--id', production_distribution_id, "--distribution-config", f"file://{config_filename}", "--region", CLOUDFRONT_REGION, '--if-match', etag])
