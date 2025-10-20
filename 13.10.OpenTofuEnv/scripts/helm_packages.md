## Helm Package Troubleshooting

### Overview
Learn how to work with Helm packages, including extracting, verifying, installing, and troubleshooting.

### Steps:
1. **Package Retrieval**
   ```bash
   export HELM_EXPERIMENTAL_OCI=1
   helm pull oci://ghcr.io/den-vasyliev/charts/my-helm-chart --version 0.1.00
   ```

2. **Package Validation and Installation**
   - Validate package: `helm lint my-helm-chart-0.1.00.tgz`
   - Install to test namespace: `helm install test my-helm-chart-0.1.00.tgz -n test`
   - Verify deployment: `kubectl get all -n test`

3. **Troubleshooting Process**
   - Check pod logs: `kubectl logs <pod-name> -n test`
   - Describe resources: `kubectl describe <resource> -n test`
   - Update installation: `helm upgrade <release-name> <chart> -n test`
   - Verify service: 
     ```bash
     kubectl port-forward <pod-name> <local-port>:<container-port> -n test
     curl localhost:<local-port>
     ```

## Load Balancing Configuration

### Overview
Configure and test load balancing between different versions of your application using NodePort services and external load balancers.

### Steps:
1. **Version Management**
   - Install second version: `helm install <release-name> <chart> --set version=2.0.0`
   - Create NodePort service: `kubectl expose deployment <deployment-name> --type=NodePort`

2. **Load Balancing Setup**
   - Configure 20/80 distribution between versions
   - Scale deployments: `kubectl scale deployment <deployment-name> --replicas=<count>`

3. **External Access**
   - Configure HAProxy: Create and apply haproxy.cfg
   - Expose service using ngrok or GitHub Codespace ports
   - Test load distribution

## Gateway API Configuration*

Implement and configure the Gateway API for your Helm package.

### Steps:
1. **Gateway Setup**
   - Create HTTPRoute configuration (htr.yaml)
   - Test configuration locally
   - Integrate into Helm chart

2. **Package Management**
   - Package chart: `helm package <chart-directory>`
   - Registry authentication: 
     ```bash
     export GITHUB_TOKEN=<your-token>
     helm registry login ghcr.io -u <username> -p $GITHUB_TOKEN
     ```
   - Push package: `helm push <package> oci://ghcr.io/<repository>`

## Best Practices
- Always validate configurations before applying them
- Use meaningful names for releases and resources
- Maintain proper version control for Helm charts

## Additional Resources
- [Helm Documentation](https://helm.sh/docs/)