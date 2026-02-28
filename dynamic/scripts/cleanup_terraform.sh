#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Main directory: ${MAIN_DIR}"
echo "Cleaning Terraform files..."

for dir in "${MAIN_DIR}"/*/; do
  dir_name="$(basename "$dir")"
  # Skip non-terraform directories
  [[ "$dir_name" == "scripts" || "$dir_name" == "environments" ]] && continue

  echo "Processing: ${dir}"
  rm -rf \
    "${dir}/.terraform" \
    "${dir}/terraform.tfstate" \
    "${dir}/terraform.tfstate.backup" \
    "${dir}/.terraform.lock.hcl"
done

echo "Cleanup complete."