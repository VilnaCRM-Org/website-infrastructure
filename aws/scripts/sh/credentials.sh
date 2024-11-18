#!/bin/bash

if ! touch config credentials; then
    echo "Error: Failed to create temporary files" >&2
    exit 1
fi

# Validate AWS credentials extraction
if ! access_key_id=$(echo "$aws_iam_output" | jq -r '.["Credentials"] | .["AccessKeyId"]') || \
   ! secret_access_key=$(echo "$aws_iam_output" | jq -r '.["Credentials"] | .["SecretAccessKey"]') || \
   ! session_token=$(echo "$aws_iam_output" | jq -r '.["Credentials"] | .["SessionToken"]'); then
    echo "Error: Failed to extract credentials from AWS response" >&2
    exit 1
fi

{
    echo "[profile terraform]"
    echo "region = ${AWS_DEFAULT_REGION}"
} > config

{
    echo "[terraform]"
    echo "aws_access_key_id = $access_key_id"
    echo "aws_secret_access_key = $secret_access_key"
    echo "aws_session_token = $session_token"
} > credentials

if ! mkdir -p ~/.aws/; then
    echo "Error: Failed to create ~/.aws directory" >&2
    exit 1
fi

if ! mv config ~/.aws/config || ! mv credentials ~/.aws/credentials; then
    echo "Error: Failed to move configuration files" >&2
    exit 1
fi
export AWS_PROFILE=terraform