#!/bin/bash
set -e

if [ -z "$PROJECT_NAME" ]; then
  echo "Error: PROJECT_NAME environment variable is not set!"
  exit 1
fi

if [ -z "$BRANCH_NAME" ]; then
  echo "Error: BRANCH_NAME environment variable is not set!"
  exit 1
fi

bucket_name="${PROJECT_NAME}-${BRANCH_NAME}"

echo "Creating EventBridge rule for bucket: $bucket_name"

aws events put-rule \
  --name "s3-cleanup-$bucket_name" \
  --schedule-expression "rate(10 minutes)"

echo "Rule created: s3-cleanup-$bucket_name"

account_id=$(aws sts get-caller-identity --query "Account" --output text)

aws events put-targets \
  --rule "s3-cleanup-$bucket_name" \
  --targets "[
    {
      \"Id\": \"1\",
      \"Arn\": \"arn:aws:lambda:eu-central-1:$account_id:function:s3-cleanup-lambda\",
      \"Input\": \"{\\\"bucket_name\\\": \\\"$bucket_name\\\"}\"
    }
  ]"

echo "EventBridge rule set up for bucket deletion."