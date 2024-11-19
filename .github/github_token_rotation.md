# GitHub Token Rotation

## Table of Contents

1. [Overview](#overview)
2. [Setting Up GitHub Token Rotation Workflow](#setting-up-github-token-rotation-workflow)
3. [Testing and Verification Procedures](#testing-and-verification-procedures)
4. [Troubleshooting Guide](#troubleshooting-guide)
5. [Security Best Practices](#security-best-practices)
6. [Operational Considerations](#operational-considerations)

## Overview

This documentation guides you through the configuration of a GitHub Actions workflow 
that automates the rotation of a GitHub token. The workflow uses a GitHub App to 
generate a new GitHub token and stores it securely in AWS Secrets Manager. It is 
designed to run on a weekly schedule or can be triggered manually. This setup ensures 
that sensitive tokens are regularly refreshed to maintain security best practices.

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

   **Security Implications of Granting Permissions**

   Each permission granted to a GitHub App extends its access to various parts of the repository or organization, so it’s essential to weigh these permissions carefully:

   - **Metadata (Read-only)**: This is minimal permission, providing basic information about the repository or organization. However, metadata can sometimes reveal sensitive project configurations or collaborator lists, so access should be granted only when necessary.

   - **Contents (Read-only)**: This permission allows the GitHub App to read repository content, which could include proprietary code, configuration files, or workflow definitions. It’s essential to use this permission only when the app genuinely needs it for tasks like automation or CI/CD workflows.

   - **Administration (Read)**: Enabling read access to repository settings lets the GitHub App view configurations but not modify them. However, it could expose critical settings or secrets related to the repository’s security and functionality.

   - **Actions (Read)**: This allows the app to access GitHub Actions settings, workflows, and logs. While this aids in monitoring and workflow management, logs may contain sensitive data, including debugging information or output with environment variables.

   - **Members (Read)**: This permission is used to verify organization membership, which is particularly useful for enforcing access controls. Still, membership lists reveal the structure of teams and roles, which could pose a risk if exposed improperly.

   **Auditing Usage of Permissions**

   To maintain oversight over the permissions and actions taken by the GitHub App:

   - **Monitor GitHub Audit Logs**: The audit logs for your GitHub Organization or Repository will display actions taken by the GitHub App, including API requests and any access to repository content. This helps in tracking and verifying appropriate usage.

   - **Use Security Overview**: GitHub provides a security overview at the organization level, summarizing GitHub Apps and OAuth Apps with access. Review it periodically to ensure that only required apps retain access.

   - **Check GitHub App Settings**: Regularly review the app’s configured permissions to verify that they align with current needs and organizational policies. Ensure no unused or excessive permissions are granted.

   - **Set Alerts for Anomalous Activity**: In case of suspicious or abnormal actions from the GitHub App, GitHub’s security settings allow admins to set alerts for specific events, which could signal potential misuse.

3. **Workflow Schedule Configuration**

   This workflow is set to rotate the token every Sunday at midnight (0 0 \* \* 0) and can be manually triggered using `workflow_dispatch`.

   - To modify the schedule, adjust the cron expression under `schedule` in the YAML file to your preferred rotation frequency.

4. **Validation Steps Post-Setup**

   - Run the workflow manually and confirm that it generates a new token and stores it in AWS Secrets Manager.
   - Verify API access using the new token to ensure that all components are correctly configured.

   **Verify GitHub App Installation**

   - Confirm that the GitHub App is correctly installed on the repository and configured to access necessary resources.

   ```bash
   curl -X GET \
     --max-time 30 \
     --retry 3 \
     --retry-delay 5 \
     -H "Authorization: Bearer ${GITHUB_TOKEN:?}" \
     -H "Accept: application/vnd.github.v3+json" \
     -s \
     -o /dev/null \
     -w "%{http_code}" \
     "https://api.github.com/app/installations" || {
      echo "Failed to verify installation" >&2
      echo "Failed to verify installation: $? (HTTP: %{http_code})" >&2
      echo "Please check token permissions and network connectivity" >&2
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
     --secret-id "${SECRET_ID:?}" \
     --query SecretString \
     --output text 2>&1 || {
         echo "Failed to retrieve secret: $?" >&2
         echo "Error: Failed to retrieve secret '${SECRET_ID}'. Please verify:" >&2
         echo "  - AWS credentials are valid" >&2
         echo "  - Secret name is correct" >&2
         echo "  - You have necessary IAM permissions" >&2
         exit 1
     } | jq -e 'length > 0' >/dev/null && \
     echo "Secret retrieved successfully and validated"
```

- **Expected Output**: The current GitHub token value stored in AWS Secrets Manager.
- **Validation**: Ensure the response contains a valid token string, which indicates that Secrets Manager is correctly storing and providing access to the token.

- **GitHub API Debugging**

  To confirm that the GitHub App is authorized and properly configured, use this command to retrieve the app details:

## Verify GitHub App configuration

```bash
curl -s -X GET \
  --connect-timeout 10 \
  --max-time 30 \
  --retry 3 \
  --retry-delay 5 \
  -H "Authorization: Bearer ${GITHUB_TOKEN:?}" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/app" | jq -e . >/dev/null 2>&1 || {
    status=$?
    echo "Error: Failed to verify GitHub App configuration (exit code: ${status})" >&2
    echo "Response: $(curl -s -X GET \
      -H "Authorization: Bearer ${GITHUB_TOKEN:?}" \
      -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/app")" >&2
    exit 1
   }
```

- **Expected Output**: JSON response containing details about the GitHub App, including id, name, and owner.
- **Validation**: Verify that the output includes accurate GitHub App information, confirming the app’s configuration and authentication status.

---

## Security Best Practices

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

## Enhanced Token Usage Guidelines

- **Token Usage Monitoring Thresholds**:
  - **API Rate Limits**: Set specific limits for API requests per hour to prevent abuse.
  - **Concurrent Operations**: Define maximum thresholds for concurrent operations allowed with each token.
  - **Maximum Token Lifetime**: Ensure tokens have a predefined maximum lifetime that aligns with organizational security standards.
- **Token Rotation Guidelines**:
  - Regularly rotate tokens, particularly when there are changes in team members or updates to repository access requirements.

---

### Additional Steps

#### Immediate Revocation of the Old Token

- **Remove Access**: Revoke the old token immediately to prevent unauthorized access from potentially compromised credentials.
- **AWS Secrets Update**: Ensure that the old token is fully removed from **AWS Secrets Manager** or any other secure storage location.

#### Audit Log Analysis for Potential Misuse

- **Examine Logs**: Conduct a thorough audit log review to identify any unauthorized or unusual activity associated with the compromised token.
- **Investigate**: Pay special attention to any access patterns or actions that deviate from standard usage.

#### Incident Documentation Requirements

- **Detailed Incident Report**: Document the incident in detail, including suspected cause, timeline of actions taken, personnel involved, and the steps followed for token rotation.
- **Lessons Learned**: Include any insights gained to improve future incident response and token security measures.

#### Post-Incident Review Process

- **Post-Mortem Analysis**: Hold a post-incident review to analyze the effectiveness of the response, identify potential gaps, and plan improvements.
- **Update Security Policies**: Revise token management and security protocols based on findings, ensuring stronger preventive measures and faster response times.

## Strengthening Security Configurations

**Consider the following security enhancements to further protect token rotation and usage**:

1. **Mandatory Audit Logging for Secrets Manager Operations**:

   - **Enable AWS CloudTrail Logging**: AWS CloudTrail allows you to log all actions associated with managing secrets in AWS Secrets Manager. This logging helps identify suspicious activities and anomalies in the usage of secrets like GitHub tokens.
   - **Retention Requirements**: Make audit logging mandatory with a specific retention period. Ensure logs are retained for a minimum of 90 days (or according to organizational policies) to comply with regulatory requirements and support incident investigation.

2. **Implement Token Usage Monitoring with AWS CloudWatch Metrics**:

   - Use AWS CloudWatch to set up metrics that track the usage of tokens in your GitHub Actions workflows. This can help detect unauthorized access attempts or unusual activity.
   - Configure CloudWatch to trigger alerts based on token-related events, such as usage frequency or successful and unsuccessful access attempts to Secrets Manager, allowing timely response to potential security threats.

3. **Add Rate-Limiting Guidelines for Token Usage**:

   - To prevent API overload and unauthorized access, set rate limits for token usage, specifying the maximum number of requests within a given time frame.
   - Consider implementing these limits at the GitHub App level to ensure the tokens’ security and sustainable use within your workflows.

4. **Encryption Requirements for Token Storage in AWS Secrets Manager**:

   - AWS Secrets Manager provides encryption at rest by default, ensuring that tokens are securely stored. This default encryption is sufficient for most applications and does not require additional KMS setup.
   - Regularly verify that Secrets Manager's encryption configuration aligns with your organization’s security policies to ensure compliance and security best practices.

5. **Access Control Policies for AWS Secrets Manager**:

   - Implement strict access control policies to limit who and what can access your tokens in Secrets Manager.
   - Use AWS Identity and Access Management (IAM) policies to define permissions for specific users, roles, or services, ensuring the principle of least privilege. Only authorized users and GitHub workflows should have access to retrieve tokens.
   - Regularly review and audit IAM policies and Secrets Manager access logs (using AWS CloudTrail) to detect and mitigate unauthorized access attempts.
   - Add IP-based access restrictions to enforce that tokens are accessed only from approved IP addresses, further securing token usage from unauthorized locations.

6. **Secure Storage Requirements for Token Backups**:

   - Store backup tokens securely, following encryption and access control best practices. It’s crucial to store backup tokens in restricted-access locations, such as AWS Secrets Manager, ensuring they are encrypted and protected by the same security policies as primary tokens.
   - Rotate backup tokens in sync with primary tokens, and maintain an audit trail of any backup token access to facilitate compliance and improve security oversight.

7. **Token Usage Quotas to Prevent Abuse**:

   - Set specific usage quotas on tokens to prevent abuse and help ensure that tokens are only used within intended parameters.
   - Define these quotas per token or workflow to limit the number of API requests and actions each token can perform.

8. **IP Allowlisting for Token Usage**:
   - Implement IP allowlisting for token usage to limit access to trusted IP addresses only.
   - Enforce this restriction in AWS Secrets Manager or GitHub’s access control settings to enhance security against unauthorized access attempts from unapproved locations.

---

## Operational Considerations

### Error Handling and Retry Strategy

Implement retries with specific exempt status codes to avoid excessive retries on certain errors.

```yaml
jobs:
  rotate-token:
    steps:
      - uses: actions/checkout@v4.1.1
      - name: Rotate Token
        uses: actions/github-script@v7.0.1
        with:
          retries: 3
          retry-exempt-status-codes: 400,401,403,404,422
          retry-delay: exponential
          base-delay: 2000
          max-delay: 10000
          backoff-factor: 2
```

- Configure the workflow to automatically retry upon failures due to transient errors.
- Use conditional steps to handle failures gracefully, ensuring no sensitive data is exposed.

### Monitoring and Alerting Setup

- Integrate alerts (e.g., using GitHub Actions or AWS CloudWatch) for failed rotations.
- Set up notifications via Slack, email, or SMS to alert the security team about failures.

## CloudWatch Alarm example

```bash
aws cloudwatch put-metric-alarm \
    --alarm-name GithubTokenRotationFailure \
    --metric-name "${METRIC_NAME:-FailedRotations}" \
    --namespace GitHub/TokenRotation \
    --dimensions Name=Environment,Value="${ENVIRONMENT:?}" \
    --statistic Sum \
    --period "${EVALUATION_PERIOD:-300}" \
    --evaluation-periods 1 \
    --threshold 1 \
    --comparison-operator GreaterThanThreshold \
    --treat-missing-data missing \
    --alarm-actions "${NOTIFICATION_SNS_TOPIC_ARN}" \
    --ok-actions "${NOTIFICATION_SNS_TOPIC_ARN}" \
    --insufficient-data-actions "${NOTIFICATION_SNS_TOPIC_ARN}" \
    --alarm-description "Monitors GitHub token rotation failures in ${ENVIRONMENT} environment" || {
      echo "Failed to create CloudWatch alarm: $?" >&2
      echo "Please verify SNS topic ARN and IAM permissions" >&2
      exit 1
    }
```

## Preventing Concurrent Execution

- Use a **mutex lock** or implement checks to prevent concurrent executions, avoiding race conditions during token updates.

### Backup Procedures for Rotation Failures

- Maintain a secure backup token as a contingency.
- Regularly verify that backup tokens are rotated in sync with the primary rotation schedule.

---

This enhanced workflow aligns permissions with **the principle of least privilege** and automates security compliance through regular, validated token rotations.
