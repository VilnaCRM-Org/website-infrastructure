#!/bin/bash
set -euo pipefail

# Check required environment variables
: "${VILNACRM_APP_ID:?Need to set VILNACRM_APP_ID}"
: "${VILNACRM_APP_PRIVATE_KEY:?Need to set VILNACRM_APP_PRIVATE_KEY}"
: "${SECRET_NAME:?Need to set SECRET_NAME}"

echo "Generating new GitHub token..."

# Authenticate as a GitHub App
jwt=$(python3 -c "
import jwt, time, os
print(jwt.encode(
    {
        'iat': int(time.time()),
        'exp': int(time.time()) + 600,
        'iss': os.getenv('VILNACRM_APP_ID')
    }, 
    os.getenv('VILNACRM_APP_PRIVATE_KEY').replace('\\n', '\n'), 
    algorithm='RS256'
))
")

# Get installation ID
response=$(curl -s \
  -H "Authorization: Bearer $jwt" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/app/installations)

installation_id=$(echo "$response" | jq -r '.[0].id')

if [ -z "$installation_id" ] || [ "$installation_id" = "null" ]; then
  echo "Failed to retrieve installation ID"
  exit 1
fi

# Create an installation access token
token_response=$(curl -s -X POST \
  -H "Authorization: Bearer $jwt" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/app/installations/$installation_id/access_tokens")

NEW_TOKEN=$(echo "$token_response" | jq -r '.token')

if [ -z "$NEW_TOKEN" ] || [ "$NEW_TOKEN" = "null" ]; then
  echo "Failed to generate new token"
  exit 1
fi

# Get the current timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create a JSON object with the token and timestamp
SECRET_JSON=$(jq -n --arg token "$NEW_TOKEN" --arg timestamp "$TIMESTAMP" \
  '{token: $token, timestamp: $timestamp}')

# Store the new JSON in AWS Secrets Manager
if ! aws secretsmanager put-secret-value \
  --secret-id "github-token" \
  --secret-string "${SECRET_JSON}" \
  --version-stage "AWSCURRENT"; then
  echo "Error: Failed to update secret in AWS Secrets Manager"
  exit 1
fi

# Verify the secret was updated
if ! aws secretsmanager describe-secret --secret-id "${SECRET_NAME}" >/dev/null 2>&1; then
  echo "Error: Failed to verify secret update"
  exit 1
fi

echo "GitHub token has been rotated and updated in AWS Secrets Manager."
