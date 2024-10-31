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
       - **Administration**: Read – Enables the app to manage repository settings, which may be useful for specific token-related configurations.
       - **Actions**: Read – Allows the app to read GitHub Actions settings, enabling better integration with workflow-related processes.
     - **Organization Permissions**:
       - **Members**: Read – Necessary if the app needs to verify organization membership for additional security checks or access controls.
     - **User Permissions**: None required.
   - Generate and store a private key securely:
     - Recommended storage format is PEM, placed in **GitHub Secrets** and never in version control.
     - Rotate the private key regularly and ensure updates are applied in GitHub Secrets.

3. **Workflow Schedule Configuration**

   This workflow is set to rotate the token every Sunday at midnight (0 0 \* \* 0) and can be manually triggered using `workflow_dispatch`.

   - To modify the schedule, adjust the cron expression under `schedule` in the YAML file to your preferred rotation frequency.

4. **Validation Steps Post-Setup**

   - Run the workflow manually and confirm that it generates a new token and stores it in AWS Secrets Manager.
   - Verify API access using the new token to ensure that all components are correctly configured.

   **Verify GitHub App Installation**

   - Confirm that the GitHub App is correctly installed on the repository and configured to access necessary resources.

     ```bash +curl -X GET \
     -H "Authorization: Bearer ${GITHUB_TOKEN:?}" \
     -H "Accept: application/vnd.github.v3+json" \
     -s \
     -o /dev/null \
     -w "%{http_code}" \
     "https://api.github.com/app/installations" || {
       echo "Failed to verify installation" >&2
       exit 1
      }
     ```

     - **Expected Response**: A JSON response listing the installations of the GitHub App, including repository details.
     - **Validation**: Check that the installation includes the target repository.

   **Verify AWS Role Configuration**

   - Confirm that the AWS role can be assumed correctly with the provided ARN.

     `bash aws sts get-caller-identity --role-arn $GITHUB_TOKEN_ROTATION_ROLE_TO_ASSUME_TEST`

     - **Expected Response**: Caller identity details, verifying that the role is correctly configured and accessible.
     - **Validation**: Ensure the response shows valid AWS account information, indicating that the role assumption was successful.

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

- **AWS Secrets Manager Debugging**

  Use the following command to check if the GitHub token is correctly stored in AWS Secrets Manager:

```bash
aws secretsmanager get-secret-value \
   --secret-id github-token \
   --query SecretString \
   --output text 2>/dev/null || {
       echo "Failed to retrieve secret" >&2
       exit 1
   } | grep -q "." && echo "Secret retrieved successfully"
```

- **Expected Output**: The current GitHub token value stored in AWS Secrets Manager.
- **Validation**: Ensure the response contains a valid token string, which indicates that Secrets Manager is correctly storing and providing access to the token.

- **GitHub API Debugging**

  To confirm that the GitHub App is authorized and properly configured, use this command to retrieve the app details:

```bash
curl -v -X GET \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "https://api.github.com/app"
```

- **Expected Output**: JSON response containing details about the GitHub App, including id, name, and owner.
- **Validation**: Verify that the output includes accurate GitHub App information, confirming the app’s configuration and authentication status.

---

### Security Best Practices

## Token Configuration and Best Practices

- **Token Expiration**: Set token expiration to a maximum of 7 days to limit exposure.
- **Required Permissions**: Limit token scopes to `metadata:read` and `contents:read`.
- **Naming Conventions**: Name tokens with a clear structure (e.g., `github-rotation-token-<timestamp>`) for better audit trails.

## Compliance Requirements

1. **SOC 2**: Ensure AWS Secrets Manager configurations align with SOC 2 requirements for secure secret storage.
2. **GDPR Logging**: Enable audit logging for token usage to maintain compliance with GDPR.
3. **Industry-Specific Compliance**: Regularly review your setup to ensure it aligns with any industry-specific standards applicable to your organization.

## Emergency Rotation Procedures

1. **Incident Response Plan**:
   - Immediately trigger a manual token rotation if a compromise is suspected.
   - Replace the compromised token in AWS Secrets Manager.
2. **Communication Protocols**: Notify relevant security personnel and stakeholders.
3. **Recovery Procedures**: Verify the new token’s functionality and perform additional testing to confirm stability.

## Strengthening Security Configurations

**Consider the following security enhancements to further protect token rotation and usage**:

1.  **Mandatory Audit Logging for Secrets Manager Operations:**:
    Enable AWS CloudTrail Logging: AWS CloudTrail allows you to log all actions associated with managing secrets in AWS Secrets Manager. This logging helps identify suspicious activities and anomalies in the usage of secrets like GitHub tokens.
    To enable CloudTrail, create or configure an existing trail in AWS and select the region where your Secrets Manager is located.
    Retention Requirements: Make audit logging mandatory with a specific retention period. Ensure logs are retained for a minimum of 90 days (or according to organizational policies) to comply with regulatory requirements and support incident investigation.

2.  **Implement Token Usage Monitoring with AWS CloudWatch Metrics**:
    Use AWS CloudWatch to set up metrics that track the usage of tokens in your GitHub Actions workflows. This can help detect unauthorized access attempts or unusual activity.
    Configure CloudWatch to trigger alerts based on token-related events, such as usage frequency or successful and unsuccessful access attempts to Secrets Manager, allowing timely response to potential security threats.

3.  **Add Rate Limiting Guidelines for Token Usage**:
    To prevent API overload and unauthorized access, set rate limits for token usage, specifying the maximum number of requests within a given time frame.
    Consider implementing these limits at the GitHub App level to ensure the tokens’ security and sustainable use within your workflows.

4.  **Encryption Requirements for Token Storage in AWS Secrets Manager**:
    AWS Secrets Manager provides encryption at rest by default, ensuring that tokens are securely stored. This default encryption is sufficient for most applications and does not require additional KMS setup.
    Regularly verify that Secrets Manager's encryption configuration aligns with your organization’s security policies to ensure compliance and security best practices.

5.  **Access Control Policies for AWS Secrets Manager**:
    Implement strict access control policies to limit who and what can access your tokens in Secrets Manager.
    Use AWS Identity and Access Management (IAM) policies to define permissions for specific users, roles, or services, ensuring the principle of least privilege. Only authorized users and GitHub workflows should have access to retrieve tokens.
    Regularly review and audit IAM policies and Secrets Manager access logs (using AWS CloudTrail) to detect and mitigate unauthorized access attempts.
    Add IP-based access restrictions to enforce that tokens are accessed only from approved IP addresses, further securing token usage from unauthorized locations.

6.  **Secure Storage Requirements for Token Backups**:
    Store backup tokens securely, following encryption and access control best practices. It’s crucial to store backup tokens in restricted-access locations, such as AWS Secrets Manager, ensuring they are encrypted and protected by the same security policies as primary tokens.
    Rotate backup tokens in sync with primary tokens, and maintain an audit trail of any backup token access to facilitate compliance and improve security oversight.

---

## Operational Considerations

### Error Handling and Retry Strategy

Implement retries with specific exempt status codes to avoid excessive retries on certain errors.

```yaml
jobs:
  rotate-token:
    steps:
      - uses: actions/checkout@v4
      - name: Rotate Token
        uses: actions/github-script@v7
        with:
          retries: 3
          retry-exempt-status-codes: 422,401
          retry-delay: exponential
          base-delay: 1000
          max-delay: 4000
```

- Configure the workflow to automatically retry upon failures due to transient errors.
- Use conditional steps to handle failures gracefully, ensuring no sensitive data is exposed.

### Monitoring and Alerting Setup

- Integrate alerts (e.g., using GitHub Actions or AWS CloudWatch) for failed rotations.
- Set up notifications via Slack, email, or SMS to alert the security team about failures.

# CloudWatch Alarm example

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name GithubTokenRotationFailure \
  --metric-name FailedRotations \
  --namespace GitHub/TokenRotation \
  --statistic Sum \
  --period 300 \
  --evaluation-periods 1 \
  --threshold 1 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions <SNS_TOPIC_ARN>
```

## Preventing Concurrent Execution

- Use a **mutex lock** or implement checks to prevent concurrent executions, avoiding race conditions during token updates.

### Backup Procedures for Rotation Failures

- Maintain a secure backup token as a contingency.
- Regularly verify that backup tokens are rotated in sync with the primary rotation schedule.

---

This enhanced workflow aligns permissions with the **principle of least privilege** and automates security compliance through regular, validated token rotations.
