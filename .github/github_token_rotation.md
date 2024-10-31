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
     - **Repository Permissions**:
       - **Metadata**: Read-only (essential for basic API access).
       - **Contents**: Read-only (required for workflow operations).
     - **Organization Permissions**: None required.
     - **User Permissions**: None required.
   - Generate and store a private key securely:
     - Recommended storage format is PEM, placed in **GitHub Secrets** and never in version control.
     - Rotate the private key regularly and ensure updates are applied in GitHub Secrets.

3. **Workflow Schedule Configuration**

   This workflow is set to rotate the token every Sunday at midnight (0 0 * * 0) and can be manually triggered using `workflow_dispatch`.

   - To modify the schedule, adjust the cron expression under `schedule` in the YAML file to your preferred rotation frequency.

4. **Validation Steps Post-Setup**

   - Run the workflow manually and confirm that it generates a new token and stores it in AWS Secrets Manager.
   - Verify API access using the new token to ensure that all components are correctly configured.

---

## Testing and Verification Procedures

### Specific Test Scenarios

1. **Basic Token Rotation**
   - Trigger manual rotation.
   - Verify that the old token is revoked.
   - Confirm the new token is active in AWS Secrets Manager.

2. **Permission Validation**
   - Test repository access to confirm permissions are set correctly.
   - Verify that the token respects API rate limits.
   - Confirm scope restrictions and ensure no unauthorized access is granted.

3. **Error Handling**
   - Test with intentionally incorrect permissions to observe error handling.
   - Simulate AWS connectivity issues to verify rollback procedures.
   - Confirm the workflow handles errors and logs them appropriately.

### Testing Token Permissions

1. Perform a series of actions allowed by the token in a test environment.
2. Ensure that the token’s permissions are scoped appropriately and that it has the **minimum required access** to perform its functions.

### Step-by-Step Validation Commands

- **Verify Token Rotation**: Use GitHub API to check the `app/installations` and `app/installations/{id}/access_tokens` endpoints.
- **Confirm Token Permissions**: Test specific actions (e.g., accessing repository contents) to ensure the token’s scope is correctly restricted.

---

## Troubleshooting Guide

### Common Error Messages

1. **"Resource not found" in AWS Secrets Manager**
   - **Cause**: Incorrect region or secret name.
   - **Solution**: Verify `AWS_REGION` and the secret’s path in Secrets Manager.

2. **"Installation not found" from GitHub API**
   - **Cause**: The GitHub App is not properly installed on the repository.
   - **Solution**: Verify that the App is installed and has necessary permissions.

3. **"Invalid private key" error**
   - **Cause**: Malformed private key format.
   - **Solution**: Ensure the private key is in proper PEM format without additional whitespace.

### Debugging Commands and Log Analysis Guidance

- **Debugging**: Set the `DEBUG` flag to true in the workflow to obtain detailed logs.
- **Log Analysis**: Review workflow logs in GitHub Actions for any errors in token generation or API interactions.

---

## Security Best Practices

### Token Configuration and Best Practices

- **Token Expiration**: Set token expiration to a maximum of 7 days to limit exposure.
- **Required Permissions**: Limit token scopes to `metadata:read` and `contents:read`.
- **Naming Conventions**: Name tokens with a clear structure (e.g., `github-rotation-token-<timestamp>`) for better audit trails.

### Compliance Requirements

1. **SOC 2**: Ensure AWS Secrets Manager configurations align with SOC 2 requirements for secure secret storage.
2. **GDPR Logging**: Enable audit logging for token usage to maintain compliance with GDPR.
3. **Industry-Specific Compliance**: Regularly review your setup to ensure it aligns with any industry-specific standards applicable to your organization.

### Emergency Rotation Procedures

1. **Incident Response Plan**:
   - Immediately trigger a manual token rotation if a compromise is suspected.
   - Replace the compromised token in AWS Secrets Manager.
2. **Communication Protocols**: Notify relevant security personnel and stakeholders.
3. **Recovery Procedures**: Verify the new token’s functionality and perform additional testing to confirm stability.

---

## Operational Considerations

### Error Handling and Retry Strategy

   Implement retries with specific exempt status codes to avoid excessive retries on certain errors.

   ```yaml
   jobs:
     rotate-token:
       steps:
         - uses: actions/checkout@v2
         - name: Rotate Token
           uses: actions/github-script@v6
           with:
             retries: 3
             retry-exempt-status-codes: 422,401

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
