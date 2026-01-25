# CEX Development Kubernetes Cluster

Production-grade K3d cluster for CEX development environment. 

## Architecture

- **Cluster Name**: cex-dev-shared01
- **Control Plane Nodes**: 3 (High Availability)
- **Worker Nodes**: 3
- **Namespaces**: rtl-dev01, rtl-prime-dev01
- **Ingress**:  NGINX Ingress Controller
- **Metrics**:  Metrics Server
- **TLS**: cert-manager
- **Registry**: Local Docker registry

## Prerequisites

```bash
# Install k3d
brew install k3d

# Verify installations
k3d version
terraform version
kubectl version
docker --version
```

## Deployment

### 1. Initialize Terraform

```bash
cd ~/k8s-clusters/cex-dev-shared01
terraform init
```

### 2. Review Plan

```bash
terraform plan
```

### 3. Deploy Cluster

```bash
terraform apply
```

Review the plan and type `yes` when prompted.

### 4. Verify Cluster

```bash
# Check cluster
k3d cluster list

# Check nodes
kubectl get nodes

# Check namespaces
kubectl get namespaces

# Check all pods
kubectl get pods -A

# Check resource quotas
kubectl get resourcequota -n rtl-dev01
kubectl get resourcequota -n rtl-prime-dev01

# Check network policies
kubectl get networkpolicies -n rtl-dev01
kubectl get networkpolicies -n rtl-prime-dev01
```

## Production Best Practices Implemented

### 1. High Availability
- 3 control plane nodes for HA
- 3 worker nodes for workload distribution

### 2. Resource Management
- Resource quotas per namespace
- Limit ranges for pods and containers
- Priority classes (high, medium, low)

### 3. Security
- Pod Security Standards (restricted)
- Network policies (default deny all)
- DNS egress allowed
- RBAC with service accounts and roles
- TLS support via cert-manager

### 4. Observability
- Metrics Server for resource monitoring
- Prometheus-ready (metrics exposed)

### 5. Networking
- NGINX Ingress Controller
- Load balancer with HTTP/HTTPS
- Custom port mappings

### 6. Storage
- Persistent volume support
- Local path provisioner

### 7. Development Experience
- Local container registry
- Easy access to services
- Proper labeling and annotations

## Usage Examples

### Deploy to rtl-dev01 namespace

```bash
# Set context
kubectl config use-context k3d-cex-dev-shared01

# Create deployment
kubectl create deployment nginx --image=nginx -n rtl-dev01

# Scale deployment
kubectl scale deployment nginx --replicas=3 -n rtl-dev01

# Expose service
kubectl expose deployment nginx --port=80 --type=ClusterIP -n rtl-dev01
```

### Use Local Registry

```bash
# Tag image
docker tag myapp:latest localhost:5000/myapp:latest

# Push to local registry
docker push localhost:5000/myapp:latest

# Use in K8s
kubectl create deployment myapp --image=k3d-cex-dev-shared01-registry:5000/myapp: latest -n rtl-dev01
```

### Access Services

```bash
# Port-forward to service
kubectl port-forward -n rtl-dev01 svc/nginx 8080:80

# Access via browser
open http://localhost:8080
```

### Monitor Resources

```bash
# Node metrics
kubectl top nodes

# Pod metrics
kubectl top pods -n rtl-dev01

# Describe resource quota
kubectl describe resourcequota -n rtl-dev01
```

## Cluster Management

### Stop Cluster

```bash
k3d cluster stop cex-dev-shared01
```

### Start Cluster

```bash
k3d cluster start cex-dev-shared01
```

### Destroy Cluster

```bash
terraform destroy
```

Or manually:

```bash
k3d cluster delete cex-dev-shared01
```

### Update Cluster

Modify `terraform.tfvars` and run:

```bash
terraform apply
```

## Troubleshooting

### Cluster not accessible

```bash
# Check cluster status
k3d cluster list

# Check Docker containers
docker ps | grep k3d

# Restart cluster
k3d cluster stop cex-dev-shared01
k3d cluster start cex-dev-shared01
```

### Pods not starting

```bash
# Check pod events
kubectl describe pod <pod-name> -n <namespace>

# Check logs
kubectl logs <pod-name> -n <namespace>

# Check resource quotas
kubectl describe resourcequota -n <namespace>
```

### Network issues

```bash
# Check network policies
kubectl get networkpolicies -n <namespace>

# Temporarily allow all traffic (debug only)
kubectl delete networkpolicy default-deny-ingress -n <namespace>
kubectl delete networkpolicy default-deny-egress -n <namespace>
```

## Configuration Files

- `main.tf`: Main Terraform configuration
- `variables.tf`: Variable definitions
- `outputs.tf`: Output definitions
- `versions.tf`: Provider versions
- `terraform.tfvars`: Environment-specific values

## Important URLs

- Kubernetes API: https://localhost:6443
- HTTP Ingress: http://localhost:8080
- HTTPS Ingress: https://localhost:8443
- Local Registry: localhost:5000

## Notes

- This cluster is designed for local development with production-grade practices
- Resource limits are set conservatively for an 8-core MacBook Pro
- Adjust resource quotas in `terraform.tfvars` based on your needs
- Network policies are restrictive by default; add allow rules as needed
- The cluster persists data in `/tmp` by default; change for production use

## Support

For issues or questions, contact the RTL development team. 
