#!/bin/bash
set -e

# Convert BRANCH_NAME to lowercase and remove invalid characters
sanitized_branch=$(echo "$BRANCH_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9.-]//g' | sed -E 's/^[.-]+|[.-]+$//g')

# If the sanitized branch name is longer than 60 characters, truncate it
if [[ ${#sanitized_branch} -gt 60 ]]; then
  sanitized_branch="${sanitized_branch:0:60}"
fi

# Export the cleaned branch name so it's available in subsequent scripts
export BRANCH_NAME="$sanitized_branch"
echo "Sanitized BRANCH_NAME: $BRANCH_NAME" 

bucket_name="${PROJECT_NAME}-${sanitized_branch}"

echo "Sending event for bucket: $bucket_name"

aws events put-events --entries "[
  {
    \"Source\": \"my.application\",
    \"DetailType\": \"S3 Bucket Cleanup\",
    \"Detail\": \"{\"bucket_name\": \"$bucket_name\"}\",
    \"Resources\": [],
    \"EventBusName\": \"default\"
  }
]"

echo "Event sent to EventBridge for bucket: $bucket_name."