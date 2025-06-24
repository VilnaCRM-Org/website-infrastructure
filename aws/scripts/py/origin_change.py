import json
import subprocess
import os

CLOUDFRONT_REGION = os.environ["CLOUDFRONT_REGION"]
config_filename = "distribution_config.json"


def fetch_distributions_ids():
    print("Fetching distribution IDs...")
    result = subprocess.check_output(
        [
            "aws",
            "cloudfront",
            "list-distributions",
            "--region",
            CLOUDFRONT_REGION,
            "--no-cli-pager",
        ]
    )
    distribution_ids = [
        item["Id"] for item in json.loads(result.decode())["DistributionList"]["Items"]
    ]
    print(f"Fetched distribution IDs: {distribution_ids}")
    return distribution_ids


def fetch_and_filter_distributions(distribution_ids) -> tuple[list[str], list[dict]]:
    print("Fetching and filtering distribution configurations...")
    filtered_configs = []
    filtered_ids = []

    for distribution_id in distribution_ids:
        config_result = subprocess.check_output(
            [
                "aws",
                "cloudfront",
                "get-distribution-config",
                "--id",
                distribution_id,
                "--region",
                CLOUDFRONT_REGION,
                "--no-cli-pager",
            ]
        )
        config = json.loads(config_result.decode())

        # Filter out distributions with "app." prefix in aliases or origins
        aliases = config["DistributionConfig"].get("Aliases", {}).get("Items", [])
        has_app_alias = any(alias.startswith("app.") for alias in aliases)

        # Also check origins for "app." patterns
        origins = config["DistributionConfig"].get("Origins", {}).get("Items", [])
        has_app_origin = any(
            "app." in origin.get("DomainName", "") for origin in origins
        )

        if not has_app_alias and not has_app_origin:
            filtered_configs.append(config)
            filtered_ids.append(distribution_id)
        else:
            if has_app_alias:
                print(
                    f"Skipping distribution {distribution_id} with app. prefix aliases: {aliases}",
                )
            if has_app_origin:
                app_origins = [
                    origin.get("DomainName", "")
                    for origin in origins
                    if "app." in origin.get("DomainName", "")
                ]
                print(
                    f"Skipping distribution {distribution_id} with app. in origins: {app_origins}",
                )

    print(f"Filtered to {len(filtered_configs)} distributions without app. prefix")
    
    if len(filtered_configs) != 2:
        raise ValueError(
            f"Expected exactly 2 distributions after filtering, but found {len(filtered_configs)}. "
            "Cannot perform origin swap."
        )
    
    return filtered_ids, filtered_configs


def swap_origins(configs):
    print("Swapping origins...")
    if len(configs) != 2:
        raise ValueError("Exactly two configurations are required to swap origins.")

    def swap_config_section(config1, config2, section):
        config1_section = config1["DistributionConfig"].get(section)
        config2_section = config2["DistributionConfig"].get(section)

        if config1_section is not None and config2_section is not None:
            (
                config1["DistributionConfig"][section],
                config2["DistributionConfig"][section],
            ) = (config2_section, config1_section)

    config1, config2 = configs

    swap_config_section(config1, config2, "Origins")

    print("Origins swapped successfully.")
    return [config1, config2]


def update_distribution_configs(distribution_ids, distribution_configs):
    print("Updating distribution configurations...")
    for distribution_id, distribution in zip(distribution_ids, distribution_configs):
        etag = distribution["ETag"]
        with open(config_filename, "w") as text_file:
            text_file.write(json.dumps(distribution["DistributionConfig"]))

        subprocess.check_output(
            [
                "aws",
                "cloudfront",
                "update-distribution",
                "--id",
                distribution_id,
                "--distribution-config",
                f"file://{config_filename}",
                "--region",
                CLOUDFRONT_REGION,
                "--if-match",
                etag,
            ]
        )
        print(f"Updated distribution {distribution_id}")

    print("Distribution configurations updated successfully.")


def main():
    print("Starting main function...")
    distribution_ids = fetch_distributions_ids()
    filtered_distribution_ids, distribution_configs = fetch_and_filter_distributions(
        distribution_ids,
    )
    updated_configs = swap_origins(distribution_configs)
    update_distribution_configs(filtered_distribution_ids, updated_configs)
    print("Main function completed.")


if __name__ == "__main__":
    main()
