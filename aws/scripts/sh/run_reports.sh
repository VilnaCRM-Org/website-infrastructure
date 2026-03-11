#!/bin/sh
set -u

log_report_warning() {
  echo "run_reports.sh: $1" >&2
}

if ! apk add --no-cache python3 aws-cli; then
  log_report_warning "failed to install report dependencies; skipping reports"
  exit 0
fi

if [ -z "${WEBSITE_GIT_REPOSITORY_LAST_COMMIT_SHA:-}" ] || [ -z "${WEBSITE_GIT_REPOSITORY_LAST_COMMIT_NAME:-}" ] || [ -z "${WEBSITE_GIT_REPOSITORY_LAST_COMMIT_AUTHOR:-}" ]; then
  if ! . "${CODEBUILD_SRC_DIR}/${SCRIPT_DIR}/sh/create_env.sh"; then
    log_report_warning "failed to reconstruct git metadata; skipping reports"
    exit 0
  fi
fi

if ! python3 "${CODEBUILD_SRC_DIR}/${SCRIPT_DIR}/py/reports.py"; then
  log_report_warning "failed to build the notification payload; skipping reports"
  exit 0
fi

if ! aws lambda invoke --function-name "ci-cd-website-$ENVIRONMENT-reports-notification" --cli-binary-format raw-in-base64-out --payload file://payload.json output.txt; then
  log_report_warning "failed to invoke the reports notification lambda; skipping reports"
fi
