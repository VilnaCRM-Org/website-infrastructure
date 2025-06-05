#!/bin/bash

# GitHub Authentication Script
# This script handles GitHub CLI authentication using AWS Secrets Manager
# Usage: source gh_auth_login.sh [exit_on_failure]
# 
# Parameters:
#   exit_on_failure: Set to "true" to exit on authentication failure (default: true)
#                   Set to "false" to continue execution on failure

set -e

EXIT_ON_FAILURE=${1:-true}

echo "Retrieving GitHub token for authentication..."

# Configure git to handle CodeBuild environment ownership issues
git config --global --add safe.directory "${CODEBUILD_SRC_DIR}" 2>/dev/null || true

# Get the GitHub token secret ID
SECRET_ID=$(aws secretsmanager list-secrets --query "SecretList[?starts_with(Name, 'github-token-') && DeletedDate==null].Name" --output text)

if [ -z "$SECRET_ID" ]; then
  echo "Error: No active GitHub token secret found."
  if [ "$EXIT_ON_FAILURE" = "true" ]; then
    exit 1
  else
    echo "Continuing without GitHub authentication..."
    exit 1
  fi
fi

# Retrieve and use the token for GitHub CLI authentication
if aws secretsmanager get-secret-value --secret-id "$SECRET_ID" --query 'SecretString' --output text | jq -r '.token' | gh auth login --with-token; then
  echo "GitHub authentication successful."
  exit 0
else
  echo "GitHub authentication failed."
  if [ "$EXIT_ON_FAILURE" = "true" ]; then
    exit 1
  else
    echo "Continuing without GitHub authentication..."
    exit 1
  fi
fi 