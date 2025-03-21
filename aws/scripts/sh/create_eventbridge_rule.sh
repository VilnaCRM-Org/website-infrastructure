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

# Generate a random number for the unique id in the target
unique_id=$((RANDOM % 900 + 100))

echo "🔧 Creating or updating EventBridge rule for: $bucket_name"

# Check if the rule already exists
existing_rule=$(aws events describe-rule --name "$rule_name" 2>/dev/null || true)

if [ -z "$existing_rule" ]; then
  # Rule does not exist, so create it
  echo "EventBridge rule does not exist. Creating new rule: $rule_name"
  aws events put-rule \
    --name "$rule_name" \
    --schedule-expression "rate(10 minutes)" \
    --state ENABLED
else
  # Rule exists, so update it (for example, changing schedule expression)
  echo "EventBridge rule exists. Updating rule: $rule_name"
  aws events put-rule \
    --name "$rule_name" \
    --schedule-expression "rate(10 minutes)" \
    --state ENABLED
fi

account_id=$(aws sts get-caller-identity --query "Account" --output text)

# Add target (Lambda) to the rule
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

echo "Lambda added as target in EventBridge rule"

# Check if the permission for EventBridge to invoke Lambda already exists
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

echo "Ready! Lambda is now triggered automatically every 10 minutes."