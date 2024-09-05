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

# Check if the script is running in the context of a pull request
if [ "$IS_PULL_REQUEST" -eq 1 ]; then
    # Store the GitHub token in a temporary file
    echo "$GITHUB_TOKEN" >token.txt
    
    # Authenticate with GitHub using the token
    if ! gh auth login --with-token <token.txt; then
        echo "Failed to authenticate with GitHub. Please check the GITHUB_TOKEN environment variable."
        exit 1
    fi
    
    # Create a pull request comment with a link to the latest version of the project
    if ! gh pr comment "$PR_NUMBER" -R "$GITHUB_REPOSITORY" --body "Latest Version is ready: http://$PROJECT_NAME-$BRANCH_NAME.s3-website.$AWS_DEFAULT_REGION.amazonaws.com"; then
        echo "Failed to create the pull request comment. Please check the provided environment variables."
        exit 1
    fi
fi