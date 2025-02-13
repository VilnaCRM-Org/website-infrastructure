#!/bin/bash

if [ -z "${BRANCH_NAME}" ]; then
  echo "Error: BRANCH_NAME is not set!"
  exit 1
fi

sanitized_branch=$(echo "$BRANCH_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9.-]//g' | sed -E 's/^[.-]+|[.-]+$//g')

if [[ ${#sanitized_branch} -gt 60 ]]; then
  sanitized_branch="${sanitized_branch:0:60}"
fi

BRANCH_NAME="$sanitized_branch"
export BRANCH_NAME
echo "Sanitized BRANCH_NAME: $BRANCH_NAME"