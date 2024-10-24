# GitHub Token Rotation

## Overview

This documentation guides you through the configuration of a GitHub Actions workflow that automates the rotation of a GitHub token. The workflow uses a GitHub App to generate a new GitHub token and stores it securely in AWS Secrets Manager. It is designed to run on a weekly schedule or can be triggered manually. This setup ensures that sensitive tokens are regularly refreshed to maintain security best practices.
Why You Might Need Token Rotation

    Security: Regular token rotation minimizes the risk of unauthorized access due to leaked or compromised tokens.
    Compliance: Many organizations follow best practices that require regular rotation of credentials to meet security and compliance standards.
    Automation: Automating the process saves time and reduces the chance of human error during manual updates.
    Integration: This setup integrates with both GitHub and AWS services, ensuring secure storage and usage of tokens.

Setting Up the GitHub Token Rotation Workflow

Step-by-Step Guide

1. GitHub Repository Configuration

First, you need to configure several secrets in your GitHub repository. These secrets are essential for the workflow to access AWS and GitHub services securely. Follow these steps:

    Go to Settings > Secrets and Variables > Actions in your GitHub repository.

    Add the following secrets:
        GITHUB_TOKEN_ROTATION_ROLE_TO_ASSUME_TEST: The AWS account role arn you will assume for token rotation in prod or test environment.
        AWS_REGION: The AWS region where your AWS Secrets Manager is located.
        VILNACRM_APP_ID: The ID of your GitHub App (needed for token generation). You can find this ID in Settings > Applications > Configure your GitHub App > App Settings.
        VILNACRM_APP_PRIVATE_KEY: The private key of your GitHub App. Generate this key from the GitHub App settings and store it securely.

2. GitHub App Configuration

You need to create and configure a GitHub App to interact with your repository:

    Navigate to Settings > Developer Settings > GitHub Apps.
    Click on New GitHub App.
    Fill in the required details for the GitHub App.
    Uncheck the active webhook option if not required.
    Set repository permissions as follows:
        Administration: Read & Write.
        Contents: Read Only.
        Metadata: Read Only.
    Generate a new private key and save it securely.
    Install the GitHub App on the desired repository.

3. Workflow Schedule Configuration

The workflow includes a schedule for weekly token rotation:

    Schedule: The workflow is set to run every Sunday at midnight (0 0 * * 0), but it can also be triggered manually using workflow_dispatch.

To modify the schedule:

    Update the cron expression under the schedule section in the YAML file according to your preferred frequency.

Detailed Variables Description
GITHUB_TOKEN_ROTATION_ROLE_TO_ASSUME_TEST - The AWS account role arn you will assume for token rotation in prod or test environment.

AWS_REGION - The AWS region where the Secrets Manager is configured. Example: us-west-2.

VILNACRM_APP_ID - The unique identifier for your GitHub App. Found in the GitHub App's settings.

VILNACRM_APP_PRIVATE_KEY - The private key used to authenticate as the GitHub App. Generate this key in the GitHub App settings.

SECRET_NAME - The name of the secret in AWS Secrets Manager where the GitHub token will be stored. Default is github-token.