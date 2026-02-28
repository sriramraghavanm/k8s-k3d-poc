#!/usr/bin/env bash

set -Eeuo pipefail

# ---------------------------------------------------------------------------
# CEX K8s Cluster Destruction — Environment-Aware
# ---------------------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

VALID_ENVS=("dev" "qa" "stg" "prod")

usage() {
  echo "Usage: $0 <environment>"
  echo "  Environments: ${VALID_ENVS[*]}"
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

[[ $# -lt 1 ]] && usage

ENV="$1"
validate_env "$ENV"

VAR_FILE="${ROOT_DIR}/environments/${ENV}.tfvars"

if [[ ! -f "$VAR_FILE" ]]; then
  echo -e "${RED}ERROR: Variable file not found: ${VAR_FILE}${NC}"
  exit 1
fi

CLUSTER_NAME="cex-${ENV}-shared01"

echo "==================================="
echo "CEX K8s Cluster Destruction"
echo "Environment : ${ENV}"
echo "Cluster     : ${CLUSTER_NAME}"
echo "==================================="
echo ""
echo -e "${RED}WARNING: This will destroy the ${ENV} cluster and ALL its resources!${NC}"
read -p "Type 'yes' to confirm: " -r
echo

if [[ ! "$REPLY" =~ ^yes$ ]]; then
  echo "Aborted."
  exit 1
fi

# Step 1 — Resources
echo "Step 1: Destroying Kubernetes resources..."
cd "${ROOT_DIR}/resources"
terraform destroy -var-file="${VAR_FILE}" -auto-approve || true

# Step 2 — Cluster
echo "Step 2: Destroying k3d cluster..."
cd "${ROOT_DIR}/cluster"
terraform destroy -var-file="${VAR_FILE}" -auto-approve

echo -e "${GREEN}Cluster '${CLUSTER_NAME}' destroyed successfully!${NC}"