#!/bin/bash
set -e

# Check if BRANCH_NAME is set; exit if it's empty or not defined
if [ -z "$BRANCH_NAME" ]; then
  echo "Error: Required environment variable BRANCH_NAME is not set or empty."
  exit 1
fi

# Convert BRANCH_NAME to lowercase and remove invalid characters
sanitized_branch=$(echo "$BRANCH_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9.-]//g' | sed -E 's/^[.-]+|[.-]+$//g')

# If the sanitized branch name is longer than 60 characters, truncate it
if [[ ${#sanitized_branch} -gt 60 ]]; then
  sanitized_branch="${sanitized_branch:0:60}"
fi

# Export the cleaned branch name so it's available in subsequent scripts
export BRANCH_NAME="$sanitized_branch"
echo "Sanitized BRANCH_NAME: $BRANCH_NAME" 