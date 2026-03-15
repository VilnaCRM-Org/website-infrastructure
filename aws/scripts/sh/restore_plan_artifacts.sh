#!/bin/bash
set -euo pipefail

destination_dir="${CODEBUILD_SRC_DIR}/terraform"
mkdir -p "${destination_dir}"

found=0
declare -A copied_plans=()
while IFS='=' read -r _ dir; do
  [ -n "${dir}" ] || continue

  while IFS= read -r -d '' plan_file; do
    plan_name="$(basename "${plan_file}")"
    destination_path="${destination_dir}/${plan_name}"
    if [[ -n "${copied_plans[${plan_name}]:-}" || -e "${destination_path}" ]]; then
      echo "Duplicate plan filename detected: ${plan_name}" >&2
      exit 1
    fi

    cp "${plan_file}" "${destination_path}"
    copied_plans["${plan_name}"]=1
    found=1
  done < <(find "${dir}" -type f -path '*/codepipeline-artifacts/plans/*.plan' -print0 2>/dev/null)
done < <(env | awk -F= '/^CODEBUILD_SRC_DIR/ { print $1 "=" $2 }')

if [ "${found}" -eq 0 ]; then
  echo "No plan artifacts found in CodeBuild source directories"
  env | awk -F= '/^CODEBUILD_SRC_DIR/ { print $1 "=" $2 }'
  exit 1
fi

ls -lh "${destination_dir}"/*.plan
