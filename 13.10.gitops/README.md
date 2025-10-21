# Application Setup Guide

This guide explains how to set up flux and start use it in k8s


## Prerequisites

- Linux/Unix-based system
- curl
- Kubernetes cluster (kind)
- GitHub personal access token (PAT)
- Git Repo
- k8s

## Installation Steps

### 1. Install Required Tools

First, install:

```bash
# Install the Flux CLI
curl -s https://fluxcd.io/install.sh | sudo bash

# Install K9S for cluster management
curl -sS https://webi.sh/k9s | sh
```

### 2. Setup Aliases

Add these helpful aliases to your shell configuration:

```bash
alias k="kubectl"
```

### 3. Initialize and Apply Infrastructure

```bash
# check connections to k8s, controllers, crds and etc.
flux check

# flux bootstrap github
flux bootstrap github \
  --owner={name} \
  --repository={reponame} \
  --branch=main \
  --path=clusters/test-cluster \
  --personal

# create ssh deployment key read/write
1. go to https://github.com/{name}/{reponame}/settings/keys
2. delete existing ssh key with name "SSH flux-system-main-flux-system..."
3. get ssh key from k8s
- kubectl -n flux-system get secret flux-system -o jsonpath='{.data.identity\.pub}' | base64 --decode
4. create ssh key with read/write access
```

# Enable Image Automation
```bash
flux install --components-extra=image-reflector-controller,image-automation-controller
```
### 4. Deploy nginx

#### create in git repo a file apps/nginx/deployment.yaml
```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.25.5 # {"$imagepolicy": "flux-system:nginx-policy"}
          ports:
            - containerPort: 80
```
#### create in git repo a file apps/nginx/kustomization.yaml
```bash
resources:
  - deployment.yaml
```

#### add new resource to clusters/my-cluster/kustomization.yaml
```bash
resources:
  - ../../../apps/nginx
```

#### run deploy manually
```bash
flux reconcile kustomization flux-system --with-source

#check deployment
flux get all -A |grep kustomization/flux-system
kubectl get deploy
```


## Next Steps - Configure Image Update Automation

#### add resources in git repo to file apps/nginx/kustomization.yaml
```bash
resources:
  - ....
  - image.yaml
  - image-update.yaml
```

#### add new resource to apps/nginx/image.yaml
```bash
apiVersion: image.toolkit.fluxcd.io/v1
kind: ImageRepository
metadata:
  name: nginx
  namespace: flux-system
spec:
  image: nginx
  interval: 1m
---
apiVersion: image.toolkit.fluxcd.io/v1
kind: ImagePolicy
metadata:
  name: nginx-policy
  namespace: flux-system
spec:
  imageRepositoryRef:
    name: nginx
  policy:
    semver:
      range: 1.25.x
```

#### add new resource to apps/nginx/image-update.yaml
```bash
apiVersion: image.toolkit.fluxcd.io/v1
kind: ImageUpdateAutomation
metadata:
  name: nginx-automation
  namespace: flux-system
spec:
  interval: 1m
  sourceRef:
    kind: GitRepository
    name: flux-system
  git:
    commit:
      author:
        name: FluxCD Bot
        email: fluxcd@users.noreply.github.com
    push:
      branch: main
  update:
    path: ./apps
```

#### run deploy manually or waite 10 minutes
```bash
flux reconcile kustomization flux-system --with-source

#check deployment
flux get all -A |grep kustomization/flux-system
flux get images all -A
kubectl get deploy

#then it should update image in deployment nginx to last version of nginx (exmpl: 1.25.5) 
```
