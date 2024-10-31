# GitHub Token Rotation

## Overview

This documentation guides you through the configuration of a GitHub Actions workflow that automates the rotation of a GitHub token. The workflow uses a GitHub App to generate a new GitHub token and stores it securely in AWS Secrets Manager. It is designed to run on a weekly schedule or can be triggered manually. This setup ensures that sensitive tokens are regularly refreshed to maintain security best practices.

### Why Token Rotation is Important

1. **Security**: Regular token rotation reduces the risk of unauthorized access due to potential token leaks or compromises.
2. **Compliance**: Many security standards require regular rotation of credentials to comply with security and compliance regulations.
3. **Automation**: Automating the process eliminates manual errors and simplifies the maintenance of secure tokens.
4. **Integration**: This setup securely integrates GitHub and AWS services, ensuring safe storage and controlled usage of tokens.

---

## Setting Up GitHub Token Rotation Workflow

### Step-by-Step Guide

1. **GitHub Repository Configuration**

   Configure necessary secrets in your GitHub repository for secure AWS and GitHub integration:

   - Navigate to **Settings > Secrets and Variables > Actions** in your GitHub repository.
   - Add the following secrets:
     - `GITHUB_TOKEN_ROTATION_ROLE_TO_ASSUME_TEST`: The ARN of the AWS role for token rotation.
     - `GITHUB_TOKEN_ROTATION_ROLE_TO_ASSUME_PROD`: The ARN of the AWS role for token rotation for prod environment.
     - `AWS_REGION`: AWS region for Secrets Manager.
     - `VILNACRM_APP_ID`: GitHub App ID (found under **Settings > Applications > Configure your GitHub App > App Settings**).
     - `VILNACRM_APP_PRIVATE_KEY`: GitHub App private key (generated in App settings and stored securely).

2. **GitHub App Configuration**

   Configure a GitHub App to manage repository access:

   - Go to **Settings > Developer Settings > GitHub Apps** and select **New GitHub App**.
   - Fill out the required fields and configure permissions:
     - **Administration**: Unnecessary, can be removed for security.
     - **Metadata**: Read-only (essential for basic API access).
     - **Contents**: Read-only (required for workflow operations).
   - Generate and store a private key securely.
   - Install the GitHub App on the intended repository.

3. **Workflow Schedule Configuration**

   This workflow is set to rotate the token every Sunday at midnight (0 0 * * 0) and can be manually triggered using `workflow_dispatch`.

   - To modify the schedule, adjust the cron expression under `schedule` in the YAML file to your preferred rotation frequency.

---

## Testing and Verification Procedures

### Testing Procedures for Sandbox Environment

1. **Set up a sandbox repository** to mimic the production environment.
2. **Add test secrets and necessary permissions** to the sandbox environment.
3. **Trigger the workflow manually** to observe the process in a controlled environment without affecting production.

### Verification of Token Rotation

1. **Validate the new token** in AWS Secrets Manager to confirm successful rotation.
2. **Verify GitHub App access** by querying the API endpoints to ensure the new token works as expected.

### Testing Token Permissions

1. Perform a series of actions allowed by the token in a test environment.
2. Ensure that the token’s permissions are scoped appropriately and that it has the **minimum required access** to perform its functions.

---

## Troubleshooting Guide

### Common Issues and Solutions

1. **Token Generation Failures**: 
   - Ensure the GitHub App has sufficient permissions.
   - Verify that the correct App ID and private key are in use.

2. **AWS Secrets Manager Errors**: 
   - Check AWS permissions for the role in use.
   - Ensure the correct `AWS_REGION` is set and the role ARN has the right policy for Secrets Manager access.

### Debug Procedures

- Use the `DEBUG` flag in the workflow for additional logging output.
- Confirm AWS IAM role assumptions and permissions align with workflow requirements.

---

## Security Best Practices

### Token Usage and Expiration

- Configure tokens with appropriate expiration periods.
- Set the workflow frequency in alignment with token expiration.

### Principle of Least Privilege

- Limit token permissions to the minimum required.
- Remove unnecessary permissions, like **Administration: Read & Write**, as noted.

### Audit Logging

- Enable audit logging in AWS and GitHub to monitor token usage.
- Regularly review access logs for any unusual activity.

### Emergency Rotation Procedures

- If a token is suspected to be compromised, trigger a **manual token rotation** and replace the compromised token in AWS Secrets Manager immediately.

---

## Operational Considerations

### Error Handling and Retry Strategy

- Configure the workflow to automatically retry upon failures due to transient errors.
- Use conditional steps to handle failures gracefully, ensuring no sensitive data is exposed.

### Monitoring and Alerting Setup

- Integrate alerts (e.g., using GitHub Actions or AWS CloudWatch) for failed rotations.
- Set up notifications via Slack, email, or SMS to alert the security team about failures.

### Preventing Concurrent Execution

- Use a **mutex lock** or implement checks to prevent concurrent executions, avoiding race conditions during token updates.

### Backup Procedures for Rotation Failures

- Maintain a secure backup token as a contingency.
- Regularly verify that backup tokens are rotated in sync with the primary rotation schedule.

---

This enhanced workflow aligns permissions with the **principle of least privilege** and automates security compliance through regular, validated token rotations.
