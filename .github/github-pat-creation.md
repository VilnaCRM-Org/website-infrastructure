# Creating a GitHub Personal Access Token with Admin Rights for a Repository

**Objective:** Create a GitHub Personal Access Token (PAT) with administrator rights for a specific repository. This token will be used for automating tasks that require administrative access, such as creating GitHub Actions secrets and managing sandbox environments for pull request previews.

**Audience:** Repository administrator or organization owner.

## Steps

1. **Authorization:** Log in to the GitHub account that is the owner of the organization or an administrator of the repository for which you need to create the token.

2. **Navigate to Token Settings:**
    * Click on your avatar in the top right corner.
    * Select **Settings**.
    * In the left menu, select **Developer settings**.
    * Select **Personal access tokens** -> **Tokens (classic)**.

3. **Generate a New Token:**
    * Click the **Generate new token** button -> **Generate new token (classic)**.

4. **Token Configuration:**
    * **Note (Description):** Enter a descriptive note, for example, `CodeBuild Access to <repository_name> repository`. This will help you identify the token later.
    * **Expiration (Validity Period):** Choose an expiration period for the token. It is recommended to set a reasonable period (for example, 7, 30, 60, or 90 days) and renew the token upon expiry. Do not select "No expiration" unless absolutely necessary. According to the best practices a reasonable period is 7 days.
    * **Select scopes (Permissions):**
        * **Crucially, select the `repo` scope.** This grants the token full access to the repository. **By selecting `repo`, you are implicitly granting the following permissions, all of which are necessary for creating and managing repository secrets:**
            * **`repo` (Full Control):**  Full control of the repository, including code, issues, pull requests, actions, projects, wiki, settings, webhooks, secrets, etc.
            * **`repo:status`:** Access to commit statuses.
            * **`repo_deployment`:** Access to deployment environments.
            * **`public_repo`:** (Only needed when working *exclusively* with public repositories.  Use `repo` for private repositories or if you need access to both public and private).
            * **`repo:invite`:** Access to repository invitations.
            * **`security_events`:** Read and write access to security events in the audit log.
            * **`admin:repo_hook`:** Full control of repository webhooks (reading, writing, pinging, and deleting).
            * **`read:org`:** Read-only access to organization membership, teams, and hook delivery data. **Required for operations like commenting on pull requests in the context of an organization.**
            * **In short, the `repo` scope provides comprehensive access, including everything required for secret management.**
        * **⚠️ Security Note:** The `repo` scope grants extensive permissions. Ensure you understand the security implications of granting full repository access. Consider using repository-specific deploy keys or GitHub Apps with more granular permissions if your use case allows.

5. **Generate Token:**
    * Click the **Generate token** button at the bottom of the page.

6. **Copy Token:**
    * **Important:** Copy the generated token and store it in a secure location. **You will not see this token again on GitHub!** Do not store the token in your code, unencrypted files, or version control systems.

## Further Actions

* This token can now be used to authenticate to GitHub when performing operations that require administrator rights to the repository.
* **It is highly recommended to store the token in a secrets management service, such as AWS Secrets Manager, for secure access and management.**
* Instructions for storing the token in AWS Secrets Manager can be found in the AWS documentation or your organization's internal documentation.

## Important Notes

* **Security:** Never store tokens in your code, version control systems, or in plain sight. Use secret managers.
* **Rotation:** Regularly rotate the GitHub token.
* **Least Privilege:** Grant the token only the minimum necessary permissions. While `repo` is required in this case, consider if more granular permissions are possible for other use cases.
* **Revoke Token:** If you suspect that a token has been compromised, immediately revoke it in your GitHub settings and generate a new one.

This guide helps you create a GitHub token with the necessary permissions. Remember that secure storage of the token is just as important as properly configuring its permissions.
