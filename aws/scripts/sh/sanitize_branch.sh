#!/bin/sh
set -e

: "${BRANCH_NAME:?BRANCH_NAME is not set}"

RAW_BRANCH_NAME="$BRANCH_NAME"
slugified_branch=$(printf '%s' "$RAW_BRANCH_NAME" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g; s/-+/-/g')

if [ -z "$slugified_branch" ]; then
  slugified_branch="branch"
fi

branch_hash=$(printf '%s' "$RAW_BRANCH_NAME" | sha1sum | cut -c1-8)
max_suffix_length=47

if [ -n "${PROJECT_NAME:-}" ]; then
  computed_max_suffix_length=$((63 - ${#PROJECT_NAME} - 1))
  if [ "$computed_max_suffix_length" -gt 9 ]; then
    max_suffix_length=$computed_max_suffix_length
  else
    max_suffix_length=10
  fi
fi

prefix_max_length=$((max_suffix_length - 9))
if [ "$prefix_max_length" -lt 1 ]; then
  prefix_max_length=1
fi

sanitized_prefix=$(printf '%s' "$slugified_branch" | cut -c1-"$prefix_max_length" | sed -E 's/-+$//')
if [ -z "$sanitized_prefix" ]; then
  sanitized_prefix="branch"
fi

export RAW_BRANCH_NAME
export BRANCH_NAME="${sanitized_prefix}-${branch_hash}"
echo "Sanitized BRANCH_NAME: $BRANCH_NAME"
