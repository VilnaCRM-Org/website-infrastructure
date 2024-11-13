#!/bin/bash

# Description:
#   This script creates a pull request comment with a link to the latest version of the project
#   when run in the context of a pull request.
#
# Inputs:
#   - IS_PULL_REQUEST: An environment variable indicating whether the script is running in the context of a pull request.
#   - GITHUB_TOKEN: An environment variable containing the GitHub token for authentication.
#   - PR_NUMBER: An environment variable containing the pull request number.
#   - GITHUB_REPOSITORY: An environment variable containing the GitHub repository name.
#   - PROJECT_NAME: An environment variable containing the project name.
#   - BRANCH_NAME: An environment variable containing the branch name.
#   - AWS_DEFAULT_REGION: An environment variable containing the AWS region.
#
# Outputs:
#   - A pull request comment with a link to the latest version of the project.
#   - Exit codes:
#     0: Success
#     1: Error (environment variables missing, authentication failed, or comment creation failed)
#
# Security:
#   - Requires GitHub token with PR comment permissions
#   - Token is retrieved securely from AWS Secrets Manager
#
# Error Handling:
#   - Validates all required environment variables
#   - Handles GitHub authentication failures
#   - Handles comment creation failures

# Validate required environment variables
for var in IS_PULL_REQUEST PR_NUMBER GITHUB_REPOSITORY PROJECT_NAME BRANCH_NAME AWS_DEFAULT_REGION; do
    if [ -z "${!var}" ]; then
        echo "Error: $var environment variable is not set"
        exit 1
    fi
done

# Set up a cleanup action to log out of GitHub after the script completes
trap 'gh auth logout' EXIT

# Check if the script is running in the context of a pull request
if [ "$IS_PULL_REQUEST" -eq 1 ]; then

    echo "Running in the context of a pull request."

    # Authenticate with GitHub
    echo "Authenticating with GitHub..."
    if ! gh auth login --with-token < <(aws secretsmanager get-secret-value --secret-id github-token --query SecretString --output text); then
        echo "GitHub authentication failed. Please ensure the github-token secret has the required permissions."
        exit 1
    fi

    echo "Authentication successful."

    # Create a pull request comment with a link to the latest version of the project
    echo "Creating pull request comment..."
    COMMENT_BODY="Latest Version is ready: http://$PROJECT_NAME-$BRANCH_NAME.s3-website.$AWS_DEFAULT_REGION.amazonaws.com"
    if ! gh pr comment "$PR_NUMBER" -R "$GITHUB_REPOSITORY" --body "$COMMENT_BODY"; then
        echo "Failed to create the pull request comment. Please check the provided environment variables."
        exit 1
    else
        echo "Successfully created a comment on PR #$PR_NUMBER with the latest version link."
    fi

    echo "Pull request comment created successfully."

else
    echo "Not a pull request. Skipping comment creation."
fi