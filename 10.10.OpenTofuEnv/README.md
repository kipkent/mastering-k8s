# Application Setup Guide

This guide explains how to set up and deploy the Ephemeral Environments using OpenTofu, Kubernetes.

## Prerequisites

- Linux/Unix-based system
- curl
- wget
- Kubernetes cluster (kind)
- Git

## Installation Steps

### 1. Install Required Tools

First, install OpenTofu and K9s:

```bash
# Install OpenTofu
curl -fsSL https://get.opentofu.org/install-opentofu.sh | sh -s -- --install-method standalone 

# Install K9S for cluster management
curl -sS https://webi.sh/k9s | sh
```

### 2. Setup Aliases

Add these helpful aliases to your shell configuration:

```bash
alias kk="sudo EDITOR='code --wait' k9s"
alias tf="sudo tofu"
alias k="sudo kubectl"
```

### 3. Initialize and Apply Infrastructure

```bash
# Navigate to bootstrap directory
cd bootstrap

# Initialize OpenTofu
sudo tofu init

# Set up GitHub authentication
# You will be prompted to enter your GitHub token securely
sudo export TF_VAR_github_token="$GITHUB_TOKEN"

# Apply the infrastructure configuration
sudo tofu apply
```

### 4. Deploy Gateway API

```bash
# Install Gateway API components
k apply -f ../gatewayapi

# Verify services
k get svc
```

### 5. Install Kind Load Balancer

```bash
wget https://github.com/kubernetes-sigs/cloud-provider-kind/releases/download/v0.6.0/cloud-provider-kind_0.6.0_linux_amd64.tar.gz
tar -xvzf cloud-provider-kind_0.6.0_linux_amd64.tar.gz -C /go/bin
/go/bin/cloud-provider-kind >/dev/null 2>&1 &
```

### 6. Deploy Application Components

```bash
# Deploy release configuration
k apply -f ../release

# Deploy preview configuration
k apply -f ../preview

# Create GitHub authentication secret in preview namespace
kubectl create secret generic github-auth \
  --from-literal=username=git \
  --from-literal=password=${GITHUB_TOKEN} \
  -n app-preview
```

### 7. Verify Deployment

To verify the deployment, you can check the LoadBalancer IP and test the endpoints:

```bash
# Get LoadBalancer IP
LB_IP=$(kubectl get svc -o jsonpath='{.items[?(@.metadata.name matches "envoy-envoy-gateway.*")].status.loadBalancer.ingress[0].ip}' -n envoy-gateway-system)

# Test the main endpoint
curl $LB_IP -HHost:kbot.example.com

# Test preview endpoint
curl $LB_IP/pr-40 -HHost:kbot.example.com
```

## Next Steps

After successful deployment:
1. Create Pull Request
```
# Test preview endpoint
# Note: use your PR number e.g. 40
curl $LB_IP/pr-40 -HHost:kbot.example.com
```
2. Merge your Pull Request
3. Create a Release
```
# Test release endpoint
curl $LB_IP -HHost:kbot.example.com
```
## Notes

- Make sure to keep your GitHub token secure
- Ensure all prerequisites are installed before starting the setup
- Check service status using `sudo kubectl get svc` if you encounter any issues
