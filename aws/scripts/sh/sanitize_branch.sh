#!/bin/sh
set -e

# Convert BRANCH_NAME to lowercase and remove invalid characters
sanitized_branch=$(echo "$BRANCH_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9.-]//g' | sed -E 's/^[.-]+|[.-]+$//g')

# If the sanitized branch name is longer than 47 characters, truncate it
# shellcheck disable=SC2000  # wc -c includes a newline, which affects the comparison with 47
if [ "$(echo "$sanitized_branch" | wc -c)" -gt 47 ]; then
  sanitized_branch=$(echo "$sanitized_branch" | cut -c 1-47)
fi

# Export the cleaned branch name so it's available in subsequent scripts
export BRANCH_NAME="$sanitized_branch"
echo "Sanitized BRANCH_NAME: $BRANCH_NAME" 