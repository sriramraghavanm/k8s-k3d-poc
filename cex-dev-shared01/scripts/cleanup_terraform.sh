#!/usr/bin/env bash

set -Eeuo pipefail

# Resolve main directory (parent of scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Main directory: ${MAIN_DIR}"
echo "Cleaning Terraform files..."

for dir in "${MAIN_DIR}"/*/; do
  # Skip scripts directory
  [[ "$(basename "$dir")" == "scripts" ]] && continue

  echo "Processing: ${dir}"

  rm -rf \
    "${dir}/.terraform" \
    "${dir}/terraform.tfstate" \
    "${dir}/terraform.tfstate.backup" \
    "${dir}/.terraform.lock.hcl"
done

echo "Cleanup complete."
