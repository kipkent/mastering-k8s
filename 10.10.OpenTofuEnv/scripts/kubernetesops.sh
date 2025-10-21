## kubeconfig

## Kubernetes resources
# Link to Kubernetes resources for a demo application
https://github.com/den-vasyliev/go-demo-app/tree/master/yaml

## rbac
# Roles та ClusterRoles
# RoleBindings та ClusterRoleBindings
# ServiceAccounts

# Kubernetes commands
k get no -o wide  # Get nodes with wide output
attach            # Attach to a running container
exec              # Execute a command in a container
logs              # Print the logs for a container
debug             # Launch a debugging session
port-forward      # Forward one or more local ports to a pod
proxy             # Run a proxy to the Kubernetes API server
run               # Run a particular image on the cluster
expose            # Take a replication controller, service, edit              # Edit a resource on the server
endpoint          # Get a endpoint of a service
scale             # Set a new size for a Deployment, ReplicaSet, 

# Docker command to execute a shell in a running container
docker exec -it 8ec114effafd sh

# Save current iptables rules
iptables-save

# Install HAProxy using Homebrew
brew install haproxy

# Cases for using Kubernetes LB
nodes             # List nodes
in lb             # internal LB
out lb            # external LB

### HELM
# Own chart
# Demo application to run in the container
https://github.com/den-vasyliev/kbot-src

# Kubernetes base resources
https://github.com/den-vasyliev/go-demo-app


# Metrics-server
# Add and update Helm repository for metrics-server
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

# Install or upgrade metrics-server with specific arguments
helm upgrade --install --set args={--kubelet-insecure-tls} metrics-server metrics-server/metrics-server --namespace kube-system

## Helm chart
# Install demo Helm chart
helm install demo ./helm --create-namespace -n demo

# Port-forwarding for a service
kubectl port-forward svc/envoy-demo-eg-0d68e7be -n demo 8888:80

# Docker login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io --username den-vasyliev --password-stdin

# Create a Kubernetes secret for Docker registry
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=git \
  --docker-password=$GITHUB_TOKEN -n test

# Patch the default service account to use the created secret
kubectl -n test patch serviceaccount default -p '{"imagePullSecrets": [{"name": "ghcr-secret"}]}'