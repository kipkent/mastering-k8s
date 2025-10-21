# Replace iptables with IPVS

### Overview
This task focuses on switching the Kubernetes network proxy mode from iptables to IPVS (IP Virtual Server) to improve performance and scalability. IPVS provides better performance for large clusters because it uses more efficient data structures (hash tables) compared to linear iptables.

### Steps:
1. **Configure and create KinD Cluster with IPVS in your main.tf file **
   ```hcl
   networking {
       kube_proxy_mode = "ipvs"
   }
   ```

2. **Cluster Node Management**
   - Find container ID: `docker ps`
   - Access node: `docker exec -it <CONTAINER_ID> bash`
   - Update package manager: `apt-get update`
   - Install IPVS tools: `apt-get install ipvsadm`

3. **Comparison and Verification**
   - Compare iptables configuration: `iptables-save`
   - Check IPVS configuration: `ipvsadm -ln`
   - Note: IPVS typically shows significantly reduced rule complexity compared to iptables


## Additional Resources
- [Kubernetes IPVS Documentation](https://kubernetes.io/docs/concepts/services-networking/service/#proxy-mode-ipvs)
- [Gateway API Documentation](https://gateway-api.sigs.k8s.io/)
