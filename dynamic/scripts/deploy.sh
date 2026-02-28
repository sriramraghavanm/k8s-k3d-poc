#!/usr/bin/env bash

set -Eeuo pipefail

# ---------------------------------------------------------------------------
# CEX K8s Cluster Deployment — Environment-Aware
# ---------------------------------------------------------------------------

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

VALID_ENVS=("dev" "qa" "stg" "prod")

usage() {
  echo "Usage: $0 <environment>"
  echo "  Environments: ${VALID_ENVS[*]}"
  echo ""
  echo "Example: $0 dev"
  exit 1
}

validate_env() {
  local env="$1"
  for valid in "${VALID_ENVS[@]}"; do
    [[ "$env" == "$valid" ]] && return 0
  done
  echo -e "${RED}ERROR: Invalid environment '${env}'.${NC}"
  usage
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
[[ $# -lt 1 ]] && usage

ENV="$1"
validate_env "$ENV"

VAR_FILE="${ROOT_DIR}/environments/${ENV}.tfvars"

if [[ ! -f "$VAR_FILE" ]]; then
  echo -e "${RED}ERROR: Variable file not found: ${VAR_FILE}${NC}"
  exit 1
fi

echo "==================================="
echo -e "${BLUE}CEX K8s Cluster Deployment${NC}"
echo "Environment : ${ENV}"
echo "Var file    : ${VAR_FILE}"
echo "==================================="
echo ""

# Step 1 — Cluster
echo -e "${BLUE}Step 1: Creating k3d cluster...${NC}"
cd "${ROOT_DIR}/cluster"
terraform init
terraform apply -var-file="${VAR_FILE}" -auto-approve
echo -e "${GREEN}✓ Cluster created successfully${NC}"
echo ""

echo "Waiting for cluster to stabilize..."
sleep 10

# Step 2 — Resources
echo -e "${BLUE}Step 2: Deploying Kubernetes resources...${NC}"
cd "${ROOT_DIR}/resources"
terraform init
terraform apply -var-file="${VAR_FILE}" -auto-approve
echo -e "${GREEN}✓ Resources deployed successfully${NC}"
echo ""

# Step 3 — Verification
CLUSTER_NAME="cex-${ENV}-shared01"
CONTEXT="k3d-${CLUSTER_NAME}"

echo -e "${BLUE}Step 3: Verifying deployment...${NC}"
echo ""
kubectl --context "${CONTEXT}" get nodes
echo ""
kubectl --context "${CONTEXT}" get namespaces
echo ""

echo -e "${GREEN}==================================="
echo "Deployment Complete!"
echo "===================================${NC}"
echo ""
echo "Cluster Name    : ${CLUSTER_NAME}"
echo "Cluster Context : ${CONTEXT}"
echo ""
echo "Useful commands:"
echo "  kubectl --context ${CONTEXT} get pods -A"
echo "  kubectl --context ${CONTEXT} get resourcequota -A"