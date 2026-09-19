#!/bin/bash
set -euo pipefail

if [ -z "${AWS_DEFAULT_REGION:-}" ]; then
  echo "Error: AWS_DEFAULT_REGION is not set."
  exit 1
fi

echo "Retrieving and using GitHub token for authentication..."
SECRET_ID=$(aws secretsmanager list-secrets --query "SecretList[?starts_with(Name, 'github-token-') && DeletedDate==null].Name" --output text)
if [ -z "$SECRET_ID" ]; then
  echo "Error: No active GitHub token secret found."
  exit 1
fi
# Retrieve secret value once and parse both token and expiry
SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ID" --query 'SecretString' --output text)
# Tokens are opaque credentials; validate the JSON type before shell extraction
# so nulls, whitespace and control characters cannot become usable credentials.
if ! GITHUB_TOKEN=$(printf '%s' "$SECRET_VALUE" | jq -er \
  '.token | strings | select(length > 0 and (test("[[:space:][:cntrl:]]") | not))' 2>/dev/null); then
  echo "Error: GitHub token must be a nonempty string without whitespace or control characters."
  exit 1
fi
EXPIRY=$(echo "$SECRET_VALUE" | jq -r '.expires_at // empty')
if [[ -n "$EXPIRY" ]] && [[ "$(date -u +%s)" -gt "$(date -u -d "$EXPIRY" +%s)" ]]; then
  echo "Error: GitHub token has expired."
  exit 1
fi
export GITHUB_TOKEN
echo "GitHub token retrieved successfully."
