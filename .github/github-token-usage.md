# Using GitHub Generated Token (ghs_*)

Objective: Use a GitHub-generated token (ghs_*) for automating tasks that require repository access, such as managing sandbox environments and integrating with AWS services.

## Table of contents

- [Using GitHub-Generated Tokens (ghs_*)](#1-using-github-generated-tokens-ghs_)
- [Storing the Token in AWS Secrets Manager](#2-storing-the-token-in-aws-secrets-manager)
  - [Retrieve the Token](#retrieve-the-token)
  - [Store the Token in AWS Secrets Manager](#store-the-token-in-aws-secrets-manager)
  - [Access the Token in Your Infrastructure Code](#access-the-token-in-your-infrastructure-code)
- [Important Notes](#important-notes)

## Steps

### 1. Using GitHub-Generated Tokens (ghs_*)

GitHub now provides automatically generated authentication tokens (ghs_* tokens) instead of manually created Personal Access Tokens (PATs). These tokens enhance security and are stored securely in AWS Secrets Manager.

### 2. Storing the Token in AWS Secrets Manager

#### Retrieve the Token

Generate a GitHub token with the required permissions by using the [GitHub token generation script](aws/scripts/sh/rotate_github_token.sh).

To run this script, you can simply use the workflow_dispatch event, which allows you to manually trigger the workflow through the GitHub UI.
This is especially useful for scenarios where you want to perform token rotation on-demand without waiting for the scheduled cron job.
You can trigger this event directly from the GitHub Actions interface, providing flexibility in managing token rotation at any time.

- For test environment: [GitHub Token Rotation (test)](workflows/github-token-rotation-test.yml)
- For prod environment: [GitHub Token Rotation (prod)](workflows/github-token-rotation-prod.yml)

#### Store the Token in AWS Secrets Manager

Once the token is generated, the script stores it securely in AWS Secrets Manager using the following AWS CLI command:

```bash
aws secretsmanager put-secret-value \
  --region "${AWS_REGION}" \
  --secret-id "${SECRET_ID}" \
  --secret-string "${SECRET_JSON}";
```

#### Access the Token in Your Infrastructure Code

Example usage in Terraform to access the token:

provider "github" {
  token = data.aws_secretsmanager_secret_version.github-token.secret_string
}

This method ensures that the GitHub token is securely stored in AWS Secrets Manager and accessed securely within your infrastructure code.

## Important Notes

- Security: Never store tokens in plain text, code repositories, or unencrypted files.

- AWS Secrets Manager: Always use AWS Secrets Manager for secure storage and retrieval.

- Least Privilege: Ensure that tokens have only the required permissions.

By following this guide, you can securely manage and use GitHub-generated tokens (ghs_*) for repository automation and infrastructure deployment.
