#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Initiating Cleanup..."
"${SCRIPT_DIR}/cleanup_terraform.sh"
rm -rf ~/.kube
echo "Completed Cleanup"