#!/bin/bash
set -e

# Выполнить python-скрипт
python3 "${CODEBUILD_SRC_DIR}/${SCRIPT_DIR}/py/reports.py"

# Вызвать AWS Lambda с payload из файла
aws lambda invoke --function-name "ci-cd-website-$ENVIRONMENT-reports-notification" --cli-binary-format raw-in-base64-out --payload file://payload.json output.txt
