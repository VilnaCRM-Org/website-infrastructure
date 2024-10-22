Overview

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
        AWS_ACCOUNT_ID: The AWS account ID where your github-actions-role is configured.
        AWS_REGION: The AWS region where your AWS Secrets Manager is located.
        GITHUB_APP_ID: The ID of your GitHub App (needed for token generation). You can find this ID in Settings > Applications > Configure your GitHub App > App Settings.
        GITHUB_PRIVATE_KEY: The private key of your GitHub App. Generate this key from the GitHub App settings and store it securely.

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

4. AWS IAM Role Configuration

The workflow assumes a specific AWS role to access AWS Secrets Manager and store the new GitHub token. Ensure that the IAM role is properly configured:

    Create an IAM role with the necessary permissions to update AWS Secrets Manager.
    Allow GitHub Actions to assume this role by setting up a trust policy that includes GitHub's identity provider.
    Add the ARN of this role to the role-to-assume field in the workflow.

Detailed Variables Description
AWS_ACCOUNT_ID - The AWS account ID containing the IAM role that GitHub Actions will assume.
AWS_REGION	The - AWS region where the Secrets Manager is configured. Example: us-west-2.
GITHUB_APP_ID - The unique identifier for your GitHub App. Found in the GitHub App's settings.
GITHUB_PRIVATE_KEY - The private key used to authenticate as the GitHub App. Generate this key in the GitHub App settings.
SECRET_NAME	- The name of the secret in AWS Secrets Manager where the GitHub token will be stored. Default is github-token.