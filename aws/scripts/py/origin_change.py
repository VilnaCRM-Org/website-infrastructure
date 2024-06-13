import json
import subprocess
import os

CLOUDFRONT_REGION = os.environ['CLOUDFRONT_REGION']

config_filename = "distribution_config.json"


def fetch_distributions_ids():
    result = subprocess.check_output(
        ['aws', 'cloudfront', 'list-distributions', '--region', CLOUDFRONT_REGION, '--no-cli-pager',])
    distrubution_ids = [item['Id'] for item in json.loads(
        result.decode())['DistributionList']['Items']]
    return distrubution_ids


def fetch_distributions_configs(distrubution_ids):
    distribution_configs = []
    for distribution_id in distrubution_ids:
        config_result = subprocess.check_output(
            ['aws', 'cloudfront', 'get-distribution-config', '--id',
                distribution_id, '--region', CLOUDFRONT_REGION, '--no-cli-pager']
        )
        config = json.loads(config_result.decode())
        distribution_configs.append(config)
    return distribution_configs


def swap_origins(configs):
    if len(configs) != 2:
        raise ValueError(
            "Exactly two configurations are required to swap origins.")

    def swap_config_section(config1, config2, section):
        config1_section = config1["DistributionConfig"].get(section)
        config2_section = config2["DistributionConfig"].get(section)

        if config1_section is not None and config2_section is not None:
            config1["DistributionConfig"][section], config2["DistributionConfig"][section] = config2_section, config1_section

    config1, config2 = configs

    swap_config_section(config1, config2, "Origins")

    return [config1, config2]


def update_distribution_configs(distribution_ids, distributions_configs):

    for distribution_id, distribution in zip(distribution_ids, distributions_configs):
        etag = distribution["ETag"]
        with open(config_filename, "w") as text_file:
            text_file.write(json.dumps(distribution['DistributionConfig']))

        subprocess.check_output(
            ['aws', 'cloudfront', 'update-distribution', '--id', distribution_id, "--distribution-config",
                f"file://{config_filename}", '--region', CLOUDFRONT_REGION, '--if-match', etag]
        )


def main():
    distribution_ids = fetch_distributions_ids()
    distribution_configs = fetch_distributions_configs(distribution_ids)
    update_distribution_configs(
        distribution_ids, swap_origins(distribution_configs))


if __name__ == "__main__":
    main()
