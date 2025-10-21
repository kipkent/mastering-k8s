
# Containerization workshop
####
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
### Install Skopeo and Dive
brew install skopeo dive trivy

#####
# Install cgroup-tools v2
sudo chmod o+w /etc/apt/sources.list
echo "deb http://cz.archive.ubuntu.com/ubuntu jammy main universe" >>/etc/apt/sources.list
sudo add-apt-repository universe
sudo apt update
sudo apt install cgroup-tools stress
#####
ls -l /sys/fs/cgroup
# Create a unified/cg1 cgroup
sudo mkdir /sys/fs/cgroup/unified
sudo mount -t cgroup2 none /sys/fs/cgroup/unified
sudo cgcreate -g cpuset,memory:unified/cg1
#####
# Check the cgroup
sudo cgget -g cpuset unified/cg1
sudo cgget -g memory unified/cg1

#####
# Set the CPU and memory limits
sudo cgset -r memory.max=100M unified/cg1
sudo cgexec -g cpu:unified/cg1 htop
sudo cgset -r memory.max=100K unified/cg1

#####
# Run the stress tool
sudo cgexec -g cpu:unified/cg1 stress --cpu 2 --timeout 60
htop
sudo cgset -r cpuset.cpus=0 unified/cg1
echo 1 >/sys/fs/cgroup/cg1/cgroup.freeze # freeze the cgroup

#####
# Create a container rootfs
mkdir rootfs
docker run busybox 
docker ps -a
docker export 1cdcdb53e6e6 | tar xf - -C rootfs
runc spec
sudo runc run demo

sudo unshare --pid --fork chroot rootfs sh # no net
sudo unshare --pid --net --fork chroot rootfs sh # with net
sudo unshare --mount-proc --pid --fork chroot rootfs sh # with proc
# inside contained mount -t proc proc /proc

# Copy the stress tool to the rootfs
cp /usr/bin/stress rootfs
# Run the stress tool in the container
sudo cgexec -g cpu:unified/cg1 unshare --mount-proc --pid --fork chroot rootfs ./stress --cpu 2 --timeout 60
####
#
# Create a container spec and run the container
runc spec
"sh", "-c", "/stress --cpu 2 --timeout 60"
sudo runc run demo
sudo runc kill demo KILL
# Add command to run in the container
"sh", "-c", "while true; do { echo -e 'HTTP/1.1 200 OK\n\nVersion: v1.0.0'; }|nc -vlp 8080;done"
runc run demo
# Kill the container
runc kill demo KILL
#
### Containerize the application
#
FROM gcr.io/distroless/base
CMD ["sh", "-c", "while true; do echo -e 'HTTP/1.1 200 OK\n\nVersion: v1.0.0' | nc -vlp 8080; done"]
EXPOSE 8080
# Build the container
docker build .
# Add token to the docker login
echo $GITHUB_TOKEN | docker login ghcr.io --username den-vasyliev --password-stdin

### Build the container image and analyze it with Dive
dive build . 
# CI option to run Dive 
CI=1 dive busybox 
# OCI image
# Skopeo commands to check different container images speecifications
skopeo --override-os linux copy docker://quay.io/quay/busybox:latest oci:/tmp/busybox-oci
tree /tmp/busybox-oci 
skopeo --override-os linux copy docker://quay.io/quay/busybox:latest dir:/tmp/busybox-dir

# Container Network
# Modify config.json task to add network namespace -> Trello


### HELM

# Demo application to run in the container
https://github.com/den-vasyliev/kbot-src

# Kubernetes base resources
https://github.com/den-vasyliev/go-demo-app

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install --set args={--kubelet-insecure-tls} metrics-server metrics-server/metrics-server --namespace kube-system

## Helm chart
helm install demo ./helm --create-namespace -n demo
kubectl port-forward svc/envoy-demo-eg-0d68e7be -n demo 8888:80
wget -O /tmp/g.png https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png
curl -F 'image=@/tmp/g.png' localhost:8888/api -HHost:demo.example.com
