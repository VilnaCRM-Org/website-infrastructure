#!/bin/bash
set -e
apk add --no-cache python3 aws-cli

python3 "${CODEBUILD_SRC_DIR}/${SCRIPT_DIR}/py/reports.py"

aws lambda invoke --function-name "ci-cd-website-$ENVIRONMENT-reports-notification" --cli-binary-format raw-in-base64-out --payload file://payload.json output.txt
