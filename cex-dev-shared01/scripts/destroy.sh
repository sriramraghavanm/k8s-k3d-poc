#!/bin/bash

set -e

echo "==================================="
echo "CEX K8s Cluster Destruction"
echo "==================================="

RED='\033[0;31m'
NC='\033[0m'

echo -e "${RED}WARNING: This will destroy the entire cluster and all resources! ${NC}"
read -p "Are you sure?  (yes/no): " -r
echo

if [[ !  $REPLY =~ ^yes$ ]]; then
    echo "Aborted."
    exit 1
fi

# Step 1: Destroy resources
echo "Step 1: Destroying Kubernetes resources..."
cd ../resources
terraform destroy -auto-approve || true
cd ..

# Step 2: Destroy cluster
echo "Step 2: Destroying k3d cluster..."
cd cluster
terraform destroy -auto-approve
cd ..

echo "Cluster destroyed successfully!"