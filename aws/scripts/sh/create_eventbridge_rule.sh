#!/bin/sh
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
rule_name="sandbox-cleanup-$(echo "$bucket_name" | sed 's/\./-/g' | cut -c1-44)"
region=${AWS_REGION:-$(aws configure get region)}

# Calculate date 7 days from now using Alpine-compatible date command
# Get current date in seconds since epoch
current_time=$(date -u +%s)
# Add 7 days in seconds (7 days * 24 hours * 60 minutes * 60 seconds)
future_time=$((current_time + 7*24*60*60))
# Convert back to date format
start_time=$(date -u -d "@$future_time" +"%M %H %d %m %Y" 2>/dev/null || date -u -r "$future_time" +"%M %H %d %m %Y")

minute=$(echo "$start_time" | awk '{print $1}')
hour=$(echo "$start_time" | awk '{print $2}')
day=$(echo "$start_time" | awk '{print $3}')
month=$(echo "$start_time" | awk '{print $4}')
year=$(echo "$start_time" | awk '{print $5}')

cron_expr="cron($minute $hour $day $month ? $year)"  

# Generate a random number for the unique id in the target
unique_id=$(awk 'BEGIN { srand(); print int(rand() * 9000) + 1000 }')

echo "🔧 Creating or updating EventBridge rule for: $bucket_name"

# Check if the rule already exists
existing_rule=$(aws events describe-rule --name "$rule_name" 2>/dev/null || true)

if [ -z "$existing_rule" ]; then
  # Rule does not exist, so create it
  echo "EventBridge rule does not exist. Creating new rule: $rule_name"
  aws events put-rule \
    --name "$rule_name" \
    --schedule-expression "$cron_expr" \
    --state ENABLED
else
  # Rule exists, so update it (for example, changing schedule expression)
  echo "EventBridge rule exists. Updating rule: $rule_name"
  aws events put-rule \
    --name "$rule_name" \
    --schedule-expression "$cron_expr" \
    --state ENABLED
fi

account_id=$(aws sts get-caller-identity --query "Account" --output text)

# 💣 Clean up old targets first to avoid hitting the limit
existing_targets=$(aws events list-targets-by-rule --rule "$rule_name" --query "Targets[].Id" --output text)
if [ -n "$existing_targets" ]; then
  echo "Removing existing targets to avoid hitting target limit..."
  # shellcheck disable=SC2086 # Intentionally unquoted to split multiple target IDs into separate CLI args
  set -- $existing_targets
  aws events remove-targets --rule "$rule_name" --ids "$@"
fi

# ✅ Add new target
aws events put-targets \
  --rule "$rule_name" \
  --targets "[{
      \"Id\": \"$unique_id\",
      \"Arn\": \"arn:aws:lambda:$region:$account_id:function:sandbox-cleanup-lambda\",
      \"InputTransformer\": {
        \"InputPathsMap\": {},
        \"InputTemplate\": \"{ \\\"bucket_name\\\": \\\"$bucket_name\\\" }\"
      }
  }]"

echo "Lambda added as target in EventBridge rule"

# Check if the permission for EventBridge to invoke Lambda already exists
existing_permission=$(aws lambda get-policy --function-name sandbox-cleanup-lambda 2>/dev/null | grep "$rule_name" || true)

if [ -z "$existing_permission" ]; then
  echo "🔒 Granting permission for EventBridge to invoke Lambda..."
  statement_id="AllowEventBridgeInvoke-${rule_name}-$(date +%s)"
  if ! aws lambda add-permission \
    --function-name sandbox-cleanup-lambda \
    --statement-id "$statement_id" \
    --action "lambda:InvokeFunction" \
    --principal events.amazonaws.com \
    --source-arn "arn:aws:events:$region:$account_id:rule/$rule_name"; then
    echo "Failed to grant permission for EventBridge to invoke Lambda."
    exit 1
  fi
  echo "Permission granted for EventBridge to invoke Lambda."
else
  echo "Lambda already has permission for EventBridge rule."
fi

echo "Ready! Lambda will be triggered automatically after 7 days."