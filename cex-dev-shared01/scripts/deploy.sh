#!/bin/bash

set -e

echo "==================================="
echo "CEX K8s Cluster Deployment"
echo "==================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Step 1: Create the cluster
echo -e "${BLUE}Step 1: Creating k3d cluster...${NC}"
cd ../cluster
terraform init
terraform apply -auto-approve
cd ..

echo -e "${GREEN}✓ Cluster created successfully${NC}"
echo ""

# Wait a bit for cluster to stabilize
echo "Waiting for cluster to stabilize..."
sleep 10

# Step 2: Deploy resources
echo -e "${BLUE}Step 2: Deploying Kubernetes resources...${NC}"
cd resources
terraform init
terraform apply -auto-approve
cd ..

echo -e "${GREEN}✓ Resources deployed successfully${NC}"
echo ""

# Step 3: Verify deployment
echo -e "${BLUE}Step 3: Verifying deployment...${NC}"
echo ""

kubectl get nodes
echo ""

kubectl get namespaces
echo ""

echo -e "${GREEN}==================================="
echo "Deployment Complete!"
echo "===================================${NC}"
echo ""
echo "Cluster Context: cex-dev-shared-01"
echo "Namespaces:  rtl-dev01, rtl-dev02"
echo ""
echo "Useful commands:"
echo "  kubectl get pods -A"
echo "  kubectl get pods -n rtl-dev01"
echo "  kubectl get pods -n rtl-dev02"
echo "  kubectl get resourcequota -n rtl-dev01"
echo "  kubectl get resourcequota -n rtl-dev02"