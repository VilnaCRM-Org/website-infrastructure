#!/bin/bash
set -euo pipefail

echo "Retrieving and using GitHub token for authentication..."
SECRET_ID=$(aws secretsmanager list-secrets --query "SecretList[?starts_with(Name, 'github-token-') && DeletedDate==null].Name" --output text)
if [ -z "$SECRET_ID" ]; then
  echo "Error: No active GitHub token secret found."
  exit 1
fi
GITHUB_TOKEN=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ID" --query 'SecretString' --output text | jq -r '.token')
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: Failed to retrieve GitHub token."
  exit 1
fi
if ! [[ $GITHUB_TOKEN =~ ^gh[ps]_[a-zA-Z0-9]{36}$ ]]; then
  echo "Error: Invalid GitHub token format."
  exit 1
fi
echo "GitHub token retrieved successfully."