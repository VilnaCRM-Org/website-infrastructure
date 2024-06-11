import json
import subprocess
import os

REGION = 'us-east-1'


def get_buckets():
    return {
        "production": os.environ['BUCKET_NAME'],
        "staging": os.environ['STAGING_BUCKET_NAME'],
    }


def fetch_distributions():
    result = subprocess.check_output(
        ['aws', 'cloudfront', 'list-distributions',
         '--region', REGION, '--no-cli-pager',]
    )
    return json.loads(result.decode())


def get_staging_distribution(distributions):
    for item in distributions["DistributionList"]["Items"]:
        if item["Staging"] == True:
            return item


def get_origins(distribution):
    return distribution["Origins"]["Items"]


def check_origins(origins):
    if origins[0]["DomainName"].startswith("staging"):
        return True
    return False


def deploy_files(bucket_name):
    return subprocess.check_output(['aws', 's3', 'sync', './out', f's3://{bucket_name}'])


def main():
    buckets = get_buckets()

    cloudfront_distributions = fetch_distributions()

    staging_distribution = get_staging_distribution(cloudfront_distributions)

    origins = get_origins(staging_distribution)

    if check_origins(origins):
        deploy_files(buckets["staging"])
        return
    deploy_files(buckets["production"])


if __name__ == "__main__":
    main()
