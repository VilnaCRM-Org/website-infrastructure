import json
import os

try:
    BRANCH_NAME = os.environ['BRANCH_NAME']
    PROJECT_NAME = os.environ['PROJECT_NAME']
except KeyError as e:
    raise ValueError(f"Required environment variable {e} is not set") from e


def create_website_configuration() -> None:
    config = {
        "IndexDocument": {
            "Suffix": "index.html",
        },
        "ErrorDocument": {
            "Key": "error.html",
        }
    }
    json_string = json.dumps(config, indent=4)

    try:
        with open('website_configuration.json', 'w') as file:
            file.write(json_string)
    except IOError as e:
        raise RuntimeError(f"Failed to write website configuration: {e}") from e

    print("Config has been written to website_configuration.json")


def create_s3_policy() -> None:
    policy = {
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "AWS": "*",
                },
                "Action": "s3:GetObject",
                "Resource": [
                    f"arn:aws:s3:::{PROJECT_NAME}-{BRANCH_NAME}/*",
                    f"arn:aws:s3:::{PROJECT_NAME}-{BRANCH_NAME}",
                ],
            },
        ]
    }

    json_string = json.dumps(policy, indent=4)

    try:
        with open('s3_policy.json', 'w') as file:
            file.write(json_string)
    except IOError as e:
        raise RuntimeError(f"Failed to write S3 policy: {e}") from e

    print("Policy has been written to s3_policy.json")


def main() -> None:
    create_website_configuration()
    create_s3_policy()


if __name__ == "__main__":
    main()
