#!/bin/bash

# Check for all required variables
if [ -z "${PROJECT_NAME}" ] || [ -z "${BRANCH_NAME}" ] || [ -z "${AWS_DEFAULT_REGION}" ]; then
    echo "Error: PROJECT_NAME, BRANCH_NAME, and AWS_DEFAULT_REGION variables must be set."
    echo "Usage: Make sure all environment variables are set before running the script."
    exit 1
fi

BUCKET_NAME="${PROJECT_NAME}-${BRANCH_NAME}"

echo "Checking if bucket ${BUCKET_NAME} exists..."

# Check if the bucket exists
if aws s3api head-bucket --bucket "${BUCKET_NAME}" --region "${AWS_DEFAULT_REGION}" 2>/dev/null; then
    echo "Bucket ${BUCKET_NAME} exists. Proceeding with deletion..."
else
    echo "Bucket ${BUCKET_NAME} does not exist. Exiting."
    exit 0
fi

# Removing objects from a bucket
if aws s3 rm "s3://${BUCKET_NAME}" --recursive --region "${AWS_DEFAULT_REGION}"; then
    echo "All objects were successfully removed from bucket ${BUCKET_NAME}."
else
    echo "Error deleting objects from bucket ${BUCKET_NAME}."
    exit 1
fi

# Removing a bucket
if aws s3api delete-bucket --bucket "${BUCKET_NAME}" --region "${AWS_DEFAULT_REGION}"; then
    echo "Bucket ${BUCKET_NAME} was successfully deleted."
else
    echo "Error deleting bucket ${BUCKET_NAME}."
    exit 1
fi