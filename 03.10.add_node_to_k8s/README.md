How add worker node with OS ubuntu 24 to controle plane:

1. In Codespace console open port 6443 to Public and with HTTPS protocol, then take forwarded url
example of url: https://psychic-space-journey-4w6xv7xj4q6fq7gw-6443.app.github.dev
2. In ubuntu server check access to k8s controle panel, we need should resived "ok":
curl -k -H "Authorization: Bearer 1234567890"  https://psychic-space-journey-4w6xv7xj4q6fq7gw-6443.app.github.dev/healthz
3. Copy Security Files from Control Plane to worker server:
/tmp/ca.crt
/tmp/token.csv

