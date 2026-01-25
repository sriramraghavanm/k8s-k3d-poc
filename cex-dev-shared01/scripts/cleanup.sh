#!/usr/bin/env bash

set -Eeuo pipefail

echo "Initiating Cleanup..."
./cleanup_terraform.sh
rm -rf ~/.kube
echo "Completed Cleanup"