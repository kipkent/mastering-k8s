#!/bin/bash

# Install OpenTofu
curl -fsSL https://get.opentofu.org/install-opentofu.sh | sh -s -- --install-method standalone 

# Install K9S to manage the cluster
curl -sS https://webi.sh/k9s | sh

# Create alias for k9s, kubectl and command-line autocompletion
alias kk="EDITOR='code --wait' k9s"
alias tf=tofu
alias k=kubectl

# Initialize Tofu
cd bootstrap
tofu init

# Prompt the user to enter the GitHub token securely
read -s GITHUB_TOKEN

# Export GitHub organization, repository, and token as environment variables
export TF_VAR_github_token="$GITHUB_TOKEN"

# Apply terrafrom configuration
tofu apply

# Install Class and GW 
k apply -f ../gatewayapi

k get svc

# Install kind loabalancer
wget https://github.com/kubernetes-sigs/cloud-provider-kind/releases/download/v0.6.0/cloud-provider-kind_0.6.0_linux_amd64.tar.gz
tar -xvzf cloud-provider-kind_0.6.0_linux_amd64.tar.gz -C /go/bin
/go/bin/cloud-provider-kind >/dev/null 2>&1 &

# Install Release
k apply -f ../release
# Retrieve the IP address of the LoadBalancer service
LB_IP=$(kubectl get svc -o jsonpath='{.items[?(@.metadata.name matches "envoy-envoy-gateway.*")].status.loadBalancer.ingress[0].ip}' -n envoy-gateway-system) 
echo "LoadBalancer IP: $LB_IP"
# Check
curl $LB_IP -HHost:kbot.example.com

# Install preview
k apply -f ../preview

# Install secrets in preview
kubectl create secret generic github-auth \
--from-literal=username=git \
--from-literal=password=${GITHUB_TOKEN} \
-n app-preview

# Open 
curl $LB_IP/pr-40 -HHost:kbot.example.com

# Merge PR
# Create Release