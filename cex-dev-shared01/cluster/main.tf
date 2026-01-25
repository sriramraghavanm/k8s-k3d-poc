locals {
  cluster_name = var.cluster_name
}

# Ensure .kube directory exists
resource "null_resource" "ensure_kube_dir" {
  provisioner "local-exec" {
    command = "mkdir -p ~/.kube"
  }
}

# Create k3d cluster
resource "null_resource" "k3d_cluster" {
  depends_on = [null_resource.ensure_kube_dir]
  
  triggers = {
    cluster_name = local.cluster_name
    servers      = var.server_count
    agents       = var.agent_count
    api_port     = var.api_port
    lb_http_port = var.lb_http_port
    lb_https_port = var.lb_https_port
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      echo "Creating k3d cluster: ${local.cluster_name}"

      # Remove any existing cluster with the same name
      k3d cluster delete ${local.cluster_name} || true

      # Ensure persistent volume path exists on host
      mkdir -p "${var.persistent_volume_path}"

      # If registry is enabled, ensure the requested port is free
      if [ "${var.enable_registry}" = "true" ]; then
        if command -v lsof >/dev/null 2>&1; then
          if lsof -nP -iTCP:${var.registry_port} -sTCP:LISTEN >/dev/null 2>&1; then
            echo "ERROR: registry port ${var.registry_port} is already in use. Choose another port or stop the service using it." >&2
            exit 1
          fi
        else
          echo "Warning: 'lsof' not found; skipping registry port availability check"
        fi
      fi

      # Build explicit port mapping args for the k3d command
      HTTP_PORT_ARG="--port '${var.lb_http_port}:80@loadbalancer'"
      HTTPS_PORT_ARG="--port '${var.lb_https_port}:443@loadbalancer'"
      REGISTRY_ARG=""
      if [ "${var.enable_registry}" = "true" ]; then
        REGISTRY_ARG="--registry-create ${local.cluster_name}-registry:0.0.0.0:${var.registry_port}"
      fi

      # Create the cluster (use eval so the assembled args with quotes are interpreted correctly)
      eval k3d cluster create "${local.cluster_name}" \
        --api-port ${var.api_port} \
        --servers ${var.server_count} \
        --agents ${var.agent_count} \
        $${HTTP_PORT_ARG} \
        $${HTTPS_PORT_ARG} \
        --volume "${var.persistent_volume_path}:/var/lib/rancher/k3s/storage@all" \
        --k3s-arg "--disable=traefik@server:*" \
        --k3s-arg "--disable=servicelb@server:*" \
        $${REGISTRY_ARG} \
        --wait

      echo "Cluster created. Setting up kubeconfig..."

      # Explicitly get kubeconfig for this cluster only
      k3d kubeconfig get "${local.cluster_name}" > ~/.kube/config.k3d.${local.cluster_name}

      # Merge kubeconfig properly (flatten) or move if no existing kubeconfig
      if [ -f ~/.kube/config ]; then
        export KUBECONFIG=~/.kube/config:~/.kube/config.k3d.${local.cluster_name}
        kubectl config view --flatten > ~/.kube/config.temp
        mv ~/.kube/config.temp ~/.kube/config
      else
        mv ~/.kube/config.k3d.${local.cluster_name} ~/.kube/config
      fi

      # Use the correct context name created by k3d
      kubectl config use-context "k3d-${local.cluster_name}"

      echo "Waiting for cluster to be ready..."
      kubectl --context "k3d-${local.cluster_name}" wait --for=condition=Ready nodes --all --timeout=300s

      echo "Cluster created successfully!"
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "Deleting k3d cluster: ${self.triggers.cluster_name}"
      k3d cluster delete ${self.triggers.cluster_name} || true
      rm -f ~/.kube/config.k3d.${self.triggers.cluster_name}
    EOT
  }
}

# Update verify step to use the k3d- prefixed context
resource "null_resource" "verify_cluster" {
  depends_on = [null_resource.k3d_cluster]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Verifying cluster access..."
      kubectl config use-context "k3d-${local.cluster_name}"
      kubectl cluster-info
      kubectl --context "k3d-${local.cluster_name}" get nodes
      echo "Verification successful!"
    EOT
  }
}