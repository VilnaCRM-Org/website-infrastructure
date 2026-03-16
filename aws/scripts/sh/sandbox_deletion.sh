#!/bin/sh

set -eu

if [ -z "${PROJECT_NAME:-}" ] || [ -z "${BRANCH_NAME:-}" ] || [ -z "${AWS_DEFAULT_REGION:-}" ]; then
    echo "Error: PROJECT_NAME, BRANCH_NAME, and AWS_DEFAULT_REGION variables must be set."
    echo "Usage: Make sure all environment variables are set before running the script."
    exit 1
fi

sanitize_legacy_branch_name() {
    sanitized_branch=$(printf '%s' "$1" \
        | tr '[:upper:]' '[:lower:]' \
        | sed 's/[^a-z0-9.-]//g' \
        | sed -E 's/^[.-]+|[.-]+$//g')

    if [ -z "$sanitized_branch" ]; then
        sanitized_branch="branch"
    fi

    printf '%s' "$sanitized_branch" | cut -c 1-47
}

delete_cleanup_rule() {
    bucket_name="$1"
    rule_name="sandbox-cleanup-$(printf '%s' "$bucket_name" | sed 's/\./-/g' | cut -c1-44)"

    if ! aws events describe-rule --name "$rule_name" --region "${AWS_DEFAULT_REGION}" >/dev/null 2>&1; then
        echo "Cleanup rule ${rule_name} does not exist."
        return 0
    fi

    target_ids=$(aws events list-targets-by-rule \
        --rule "$rule_name" \
        --region "${AWS_DEFAULT_REGION}" \
        --query 'Targets[].Id' \
        --output text)

    if [ -n "$target_ids" ] && [ "$target_ids" != "None" ]; then
        echo "Removing EventBridge targets from ${rule_name}..."
        # shellcheck disable=SC2086 # AWS CLI expects one argument per target id.
        aws events remove-targets --rule "$rule_name" --ids $target_ids --region "${AWS_DEFAULT_REGION}" >/dev/null
    fi

    echo "Deleting EventBridge cleanup rule ${rule_name}..."
    aws events delete-rule --name "$rule_name" --region "${AWS_DEFAULT_REGION}"
}

delete_bucket() {
    bucket_name="$1"

    echo "Checking if bucket ${bucket_name} exists..."
    if ! aws s3api head-bucket --bucket "${bucket_name}" --region "${AWS_DEFAULT_REGION}" 2>/dev/null; then
        echo "Bucket ${bucket_name} does not exist."
        return 1
    fi

    echo "Bucket ${bucket_name} exists. Proceeding with deletion..."
    delete_cleanup_rule "${bucket_name}"

    if aws s3 rm "s3://${bucket_name}" --recursive --region "${AWS_DEFAULT_REGION}"; then
        echo "All objects were successfully removed from bucket ${bucket_name}."
    else
        echo "Error deleting objects from bucket ${bucket_name}."
        exit 1
    fi

    if aws s3api delete-bucket --bucket "${bucket_name}" --region "${AWS_DEFAULT_REGION}"; then
        echo "Bucket ${bucket_name} delete request completed."
    else
        echo "Error deleting bucket ${bucket_name}."
        exit 1
    fi

    if aws s3api head-bucket --bucket "${bucket_name}" --region "${AWS_DEFAULT_REGION}" 2>/dev/null; then
        echo "Bucket ${bucket_name} still exists after deletion."
        exit 1
    fi

    echo "Bucket ${bucket_name} was successfully deleted."
    return 0
}

raw_branch_name="${RAW_BRANCH_NAME:-${BRANCH_NAME}}"
legacy_branch_name=$(sanitize_legacy_branch_name "${raw_branch_name}")
legacy_bucket_name="${PROJECT_NAME}-${legacy_branch_name}"
current_bucket_name="${PROJECT_NAME}-${BRANCH_NAME}"

deleted_any_bucket=0

if delete_bucket "${current_bucket_name}"; then
    deleted_any_bucket=1
fi

if [ "${legacy_bucket_name}" != "${current_bucket_name}" ] && delete_bucket "${legacy_bucket_name}"; then
    deleted_any_bucket=1
fi

if [ "${deleted_any_bucket}" -eq 0 ]; then
    echo "No matching sandbox buckets were found for deletion."
fi
