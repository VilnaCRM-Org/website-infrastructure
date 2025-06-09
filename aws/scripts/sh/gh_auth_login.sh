#!/bin/bash

# GitHub Authentication Script
# This script handles GitHub CLI authentication using AWS Secrets Manager

set -e

echo "Retrieving GitHub token for authentication..."

# Configure git to handle CodeBuild environment ownership issues
git config --global --add safe.directory "${CODEBUILD_SRC_DIR}" 2>/dev/null || true

# Get the GitHub token secret ID
SECRET_ID=$(aws secretsmanager list-secrets --query "SecretList[?starts_with(Name, 'github-token-') && DeletedDate==null].Name" --output text)

if [ -z "$SECRET_ID" ]; then
  echo "Error: No active GitHub token secret found."
  exit 1
fi

# Retrieve and use the token for GitHub CLI authentication
if aws secretsmanager get-secret-value --secret-id "$SECRET_ID" --query 'SecretString' --output text | jq -r '.token' | gh auth login --with-token; then
  echo "GitHub authentication successful."
  exit 0
else
  echo "GitHub authentication failed."
  exit 1
fi 