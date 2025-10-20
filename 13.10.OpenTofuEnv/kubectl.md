# Preview Environment Commands Cheatsheet

## Initial Setup Commands

### Infrastructure Components

The environment includes:
1. KinD Cluster - Local Kubernetes cluster
2. Flux Operator - GitOps controller
3. Flux Instance - GitOps runtime
4. Envoy Gateway - API Gateway/Ingress
5. Kbot Application - Sample application deployment

### Environment Setup

```bash
# Install OpenTofu (Terraform alternative)
curl -fsSL https://get.opentofu.org/install-method.sh | sh -s -- --install-method standalone

# Install K9s (Kubernetes UI)
curl -sS https://webi.sh/k9s | sh
```

### Repository Configuration
```bash
# Initialize OpenTofu in bootstrap directory
cd bootstrap
tofu init

# Set required environment variables
export TF_VAR_github_org="your-account-name"
export TF_VAR_github_repository="your-repo-name"
export TF_VAR_github_token="your-github-token"

# Apply infrastructure configuration
tofu apply
```

## Kubernetes Management

### Useful Aliases
```bash
# K9s with VS Code integration
alias kk="EDITOR='code --wait' k9s"

# kubectl shorthand
alias k=kubectl
```

### Basic Commands
```bash
# Get Envoy Gateway service
export ENVOY_SERVICE=$(kubectl get svc -n envoy-gateway-system \
  --selector=gateway.envoyproxy.io/owning-gateway-namespace=default,gateway.envoyproxy.io/owning-gateway-name=eg \
  -o jsonpath='{.items[0].metadata.name}')

# Port forward Envoy Gateway
kubectl -n envoy-gateway-system port-forward service/${ENVOY_SERVICE} 8888:80
```

## Flux CD Operations

### Flux Secret Management
```bash
# Create Flux GitHub authentication secret
flux -n app-preview create secret git github-auth \
  --url=https://github.com/org/app \
  --username=flux \
  --password=${GITHUB_TOKEN}
```

## Resource Management

The repository contains several custom resources in the `preview/` directory:
- `ResourceSet.yaml`: Defines resource sets for preview environments
- `Gateway.yaml`: Configures Envoy Gateway
- `PreviewEnv.yaml`: Preview environment configuration
- `FluxInstance.yaml`: Flux CD instance configuration
- `Notification.yaml`: Notification settings
- `ResourceSetInputProvider.yaml`: Input provider configuration

To apply these resources:
```bash
# Apply custom resources
kubectl apply -f preview
kubectl apply -f gatewayapi
```


### OpenTofu/Terraform Commands Cheatsheet

#### Basic Commands
```bash
# Initialize working directory
tofu init
terraform init

# Preview changes
tofu plan
terraform plan

# Apply changes
tofu apply
terraform apply

# Destroy infrastructure
tofu destroy
terraform destroy

# Show current state
tofu show
terraform show
```

### Kubectl Commands Cheatsheet

#### Cluster Management
```bash
# Display version and check cluster connectivity
kubectl version

# Check the initial resources
kubectl get all -A

# Display cluster information
kubectl cluster-info

# Check the health status of cluster components
kubectl get componentstatuses

# Get all nodes in the cluster
kubectl get nodes
kubectl get nodes -o wide

# Get cluster events
kubectl get events
```

#### Pod Operations
```bash
# List all pods
kubectl get pods
kubectl get pods --all-namespaces
kubectl get pods -o wide

# Get pod details
kubectl describe pod <pod-name>

# Get pod logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>  # Follow log output

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/bash

# Delete pod
kubectl delete pod <pod-name>
```

#### Deployment Operations
```bash
# List deployments
kubectl get deployments

# Create deployment
kubectl create deployment <name> --image=<image>

# Scale deployment
kubectl scale deployment <name> --replicas=<number>

# Update deployment image
kubectl set image deployment/<name> <container>=<image>

# Rollout commands
kubectl rollout status deployment/<name>
kubectl rollout history deployment/<name>
kubectl rollout undo deployment/<name>
```

#### Service Operations
```bash
# List services
kubectl get services

# Create service
kubectl expose deployment <name> --port=<port> --type=ClusterIP

# Delete service
kubectl delete service <name>
```

#### ConfigMap and Secrets
```bash
# Create configmap
kubectl create configmap <name> --from-file=<path/to/file>

# Create secret
kubectl create secret generic <name> --from-literal=key=value

# Get configmaps/secrets
kubectl get configmaps
kubectl get secrets
```

#### Namespace Operations
```bash
# List namespaces
kubectl get namespaces

# Create namespace
kubectl create namespace <name>

# Set default namespace
kubectl config set-context --current --namespace=<name>
```

#### Context and Configuration
```bash
# Show current context
kubectl config current-context

# List all contexts
kubectl config get-contexts

# Switch context
kubectl config use-context <context-name>
```

#### Resource Monitoring
```bash
# Show resource usage
kubectl top nodes
kubectl top pods

# Watch resources
kubectl get pods --watch
kubectl get nodes --watch
```