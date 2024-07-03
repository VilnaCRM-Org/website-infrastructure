import json
import os

BRANCH_NAME = os.environ['BRANCH_NAME']
PROJECT_NAME = os.environ['PROJECT_NAME']


def create_website_configuration():
    config = {
        "IndexDocument": {
            "Suffix": "index.html"
        },
        "ErrorDocument": {
            "Key": "error.html"
        }
    }
    json_string = json.dumps(config, indent=4)

    # Step 3: Write the JSON string to a file
    with open('website_configuration.json', 'w') as file:
        file.write(json_string)

    print("Config has been written to website_configuration.json")


def create_s3_policy():
    policy = {
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "AWS": "*"
                },
                "Action": "s3:GetObject",
                "Resource": [
                    f"arn:aws:s3:::{PROJECT_NAME}-{BRANCH_NAME}/*",
                    f"arn:aws:s3:::{PROJECT_NAME}-{BRANCH_NAME}"
                ]
            }
        ]
    }

    json_string = json.dumps(policy, indent=4)

    # Step 3: Write the JSON string to a file
    with open('s3_policy.json', 'w') as file:
        file.write(json_string)

    print("Policy has been written to s3_policy.json")


def main():
    create_website_configuration()
    create_s3_policy()


if __name__ == "__main__":
    main()
