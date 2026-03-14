#!/bin/bash
set -euo pipefail

source_dir="${CODEBUILD_SRC_DIR}/terraform"
destination_dir="${CODEBUILD_SRC_DIR}/codepipeline-artifacts/plans"

mkdir -p "${destination_dir}"

if ! compgen -G "${source_dir}/*.plan" >/dev/null; then
  echo "No Terraform plan files found in ${source_dir}"
  exit 1
fi

cp "${source_dir}"/*.plan "${destination_dir}/"
ls -lh "${destination_dir}"
