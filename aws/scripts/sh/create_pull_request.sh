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

set -euo pipefail

# Validate required environment variables
for var in IS_PULL_REQUEST GITHUB_TOKEN PR_NUMBER GITHUB_REPOSITORY PROJECT_NAME BRANCH_NAME AWS_DEFAULT_REGION; do
    if [ -z "${!var}" ]; then
        echo "Error: $var environment variable is not set"
        exit 1
    fi
done

# Check if the script is running in the context of a pull request
if [ "$IS_PULL_REQUEST" -eq 1 ]; then

    echo "Running in the context of a pull request."

    # Authenticate with GitHub
    echo "Authenticating with GitHub..."
    if ! echo "$GITHUB_TOKEN" | gh auth login --with-token; then
        echo "GitHub authentication failed. Please ensure the GITHUB_TOKEN has the required permissions."
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
