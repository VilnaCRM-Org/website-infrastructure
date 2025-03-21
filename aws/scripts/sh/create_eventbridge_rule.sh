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
rule_name="s3-cleanup-$bucket_name"
region="eu-central-1"

# Generating unique target ID using uuidgen
unique_id=$(uuidgen)

# Creating EventBridge rule
echo "🔧 Creating EventBridge rule for: $bucket_name"

aws events put-rule \
  --name "$rule_name" \
  --schedule-expression "rate(10 minutes)" \
  --state ENABLED

echo "✅ EventBridge rule created: $rule_name"

account_id=$(aws sts get-caller-identity --query "Account" --output text)

# Adding Lambda as target to EventBridge rule with unique ID
aws events put-targets \
  --rule "$rule_name" \
  --targets "[{
      \"Id\": \"$unique_id\",
      \"Arn\": \"arn:aws:lambda:$region:$account_id:function:s3-cleanup-lambda\",
      \"InputTransformer\": {
        \"InputPathsMap\": {},
        \"InputTemplate\": \"{ \\\"bucket_name\\\": \\\"$bucket_name\\\" }\"
      }
  }]"

echo "✅ Lambda added as a target in EventBridge rule with unique ID: $unique_id"

# Checking if permission already exists for EventBridge to invoke Lambda
existing_permission=$(aws lambda get-policy --function-name s3-cleanup-lambda 2>/dev/null | grep "$rule_name" || true)

if [ -z "$existing_permission" ]; then
  echo "🔒 Granting permission for EventBridge to invoke Lambda..."
  aws lambda add-permission \
    --function-name s3-cleanup-lambda \
    --statement-id "AllowEventBridgeInvoke-$rule_name" \
    --action "lambda:InvokeFunction" \
    --principal events.amazonaws.com \
    --source-arn "arn:aws:events:$region:$account_id:rule/$rule_name"
else
  echo "Lambda already has permission for EventBridge rule."
fi

echo "Done! Lambda will now be invoked automatically after 10 minutes."