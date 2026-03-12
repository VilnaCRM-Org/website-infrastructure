#!/bin/bash

# GitHub Authentication Script
# This script handles GitHub CLI authentication using AWS Secrets Manager.
# It may be executed directly or sourced from another shell script.

set -e

if (return 0 2>/dev/null); then
  gh_auth_login_sourced=1
else
  gh_auth_login_sourced=0
fi

gh_auth_login_finish() {
  if [ "$gh_auth_login_sourced" -eq 1 ]; then
    return "$1"
  fi

  exit "$1"
}

gh_auth_login_main() {
  echo "Retrieving GitHub token for authentication..."

  # Configure git to handle CodeBuild environment ownership issues.
  git config --global --add safe.directory "${CODEBUILD_SRC_DIR}" 2>/dev/null || true

  # Get the GitHub token secret ID.
  SECRET_ID=$(aws secretsmanager list-secrets --query "SecretList[?starts_with(Name, 'github-token-') && DeletedDate==null].Name" --output text)

  if [ -z "$SECRET_ID" ]; then
    echo "Error: No active GitHub token secret found."
    return 1
  fi

  # Retrieve and use the token for GitHub CLI authentication.
  if aws secretsmanager get-secret-value --secret-id "$SECRET_ID" --query 'SecretString' --output text | jq -r '.token' | gh auth login --with-token; then
    echo "GitHub authentication successful."
    return 0
  fi

  echo "GitHub authentication failed."
  return 1
}

if gh_auth_login_main "$@"; then
  gh_auth_login_finish 0
else
  gh_auth_login_finish 1
fi
