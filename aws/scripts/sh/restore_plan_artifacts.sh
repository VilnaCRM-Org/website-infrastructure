#!/bin/bash
set -euo pipefail

destination_dir="${CODEBUILD_SRC_DIR}/terraform"
mkdir -p "${destination_dir}"

found=0
while IFS='=' read -r _ dir; do
  [ -n "${dir}" ] || continue

  while IFS= read -r -d '' plan_file; do
    cp "${plan_file}" "${destination_dir}/"
    found=1
  done < <(find "${dir}" -type f -path '*/codepipeline-artifacts/plans/*.plan' -print0 2>/dev/null)
done < <(env | awk -F= '/^CODEBUILD_SRC_DIR/ { print $1 "=" $2 }')

if [ "${found}" -eq 0 ]; then
  echo "No plan artifacts found in CodeBuild source directories"
  env | awk -F= '/^CODEBUILD_SRC_DIR/ { print $1 "=" $2 }'
  exit 1
fi

ls -lh "${destination_dir}"/*.plan
