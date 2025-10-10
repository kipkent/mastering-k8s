How add worker node with OS ubuntu 24 to controle plane:

1. In Codespace console open port 6443 to Public and with HTTPS protocol, then take **forwarded url**

example of url: https://psychic-space-journey-4w6xv7xj4q6fq7gw-6443.app.github.dev

2. In ubuntu server check access to k8s controle panel, we need should resived "ok":

curl -k -H "Authorization: Bearer 1234567890"  https://psychic-space-journey-4w6xv7xj4q6fq7gw-6443.app.github.dev/healthz

3. Copy Security Files from Control Plane server to worker server:

from /var/lib/kubelet/ca.crt  to /tmp/ca.crt

The token.csv is generate from script **setup_node.sh**

4. In the node worker server - change **forwarded url** of parameter **server** in scritp **setup_node.sh** and run it: bash setup_node.sh start

