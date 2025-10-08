#!/bin/bash

# Function to check if a process is running
is_running() {
    pgrep -f "$1" >/dev/null
}

# Function to check if all components are running
check_running() {
    is_running "etcd" && \
    is_running "kube-apiserver" && \
    is_running "kube-controller-manager" && \
    is_running "cloud-controller-manager" && \
    is_running "kube-scheduler" && \
    is_running "kubelet" && \
    is_running "containerd"
}

# Function to kill process if running
stop_process() {
    if is_running "$1"; then
        echo "Stopping $1..."
        sudo pkill -f "$1" || true
        while is_running "$1"; do
            sleep 1
        done
    fi
}

download_components() {
    # Create necessary directories if they don't exist
    sudo mkdir -p ./kubebuilder/bin
    sudo mkdir -p /etc/cni/net.d
    sudo mkdir -p /var/lib/kubelet
    sudo mkdir -p /etc/kubernetes/manifests
    sudo mkdir -p /var/log/kubernetes
    sudo mkdir -p /etc/containerd/
    sudo mkdir -p /run/containerd

    # Download kubebuilder tools if not present
    if [ ! -f "kubebuilder/bin/etcd" ]; then
        echo "Downloading kubebuilder tools..."
        curl -L https://storage.googleapis.com/kubebuilder-tools/kubebuilder-tools-1.30.0-linux-amd64.tar.gz -o /tmp/kubebuilder-tools.tar.gz
        sudo tar -C ./kubebuilder --strip-components=1 -zxf /tmp/kubebuilder-tools.tar.gz
        rm /tmp/kubebuilder-tools.tar.gz
        sudo chmod -R 755 ./kubebuilder/bin
    fi

    if [ ! -f "kubebuilder/bin/kubelet" ]; then
        echo "Downloading kubelet..."
        sudo curl -L "https://dl.k8s.io/v1.30.0/bin/linux/amd64/kubelet" -o kubebuilder/bin/kubelet
        sudo chmod 755 kubebuilder/bin/kubelet
    fi

    # Install CNI components if not present
    if [ ! -d "/opt/cni" ]; then
        sudo mkdir -p /opt/cni
        
        echo "Installing containerd..."
        wget https://github.com/containerd/containerd/releases/download/v2.0.5/containerd-static-2.0.5-linux-amd64.tar.gz -O /tmp/containerd.tar.gz
        sudo tar zxf /tmp/containerd.tar.gz -C /opt/cni/
        rm /tmp/containerd.tar.gz

        echo "Installing runc..."
        sudo curl -L "https://github.com/opencontainers/runc/releases/download/v1.2.6/runc.amd64" -o /opt/cni/bin/runc

        echo "Installing CNI plugins..."
        wget https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.2.tgz -O /tmp/cni-plugins.tgz
        sudo tar zxf /tmp/cni-plugins.tgz -C /opt/cni/bin/
        rm /tmp/cni-plugins.tgz

        # Set permissions for all CNI components
        sudo chmod -R 755 /opt/cni
    fi

    if [ ! -f "kubebuilder/bin/kube-controller-manager" ]; then
        echo "Downloading additional components..."
        sudo curl -L "https://dl.k8s.io/v1.30.0/bin/linux/amd64/kube-controller-manager" -o kubebuilder/bin/kube-controller-manager
        sudo curl -L "https://dl.k8s.io/v1.30.0/bin/linux/amd64/kube-scheduler" -o kubebuilder/bin/kube-scheduler
        sudo curl -L "https://dl.k8s.io/v1.30.0/bin/linux/amd64/cloud-controller-manager" -o kubebuilder/bin/cloud-controller-manager
        sudo chmod 755 kubebuilder/bin/kube-controller-manager
        sudo chmod 755 kubebuilder/bin/kube-scheduler
        sudo chmod 755 kubebuilder/bin/cloud-controller-manager
    fi
}

start() {
    HOST_IP=$(hostname -I | awk '{print $1}')
    
    # Download components if needed
    download_components
    
    # Generate certificates and tokens if they don't exist
    if [ ! -f "/tmp/sa.key" ]; then
        openssl genrsa -out /tmp/sa.key 2048
        openssl rsa -in /tmp/sa.key -pubout -out /tmp/sa.pub
    fi

    if [ ! -f "/tmp/token.csv" ]; then
        TOKEN="1234567890"
        echo "${TOKEN},admin,admin,system:masters" > /tmp/token.csv
    fi

    # Always regenerate and copy CA certificate to ensure it exists
    echo "Generating CA certificate..."
    openssl genrsa -out /tmp/ca.key 2048
    openssl req -x509 -new -nodes -key /tmp/ca.key -subj "/CN=kubelet-ca" -days 365 -out /tmp/ca.crt
    sudo mkdir -p /var/lib/kubelet/pki
    sudo cp /tmp/ca.crt /var/lib/kubelet/ca.crt
    sudo cp /tmp/ca.crt /var/lib/kubelet/pki/ca.crt
    sudo cp /tmp/sa.key /etc/kubernetes/sa.key
    sudo cp /tmp/token.csv /etc/kubernetes/token.csv
    sudo cp /tmp/sa.pub /etc/kubernetes/sa.pub

    # Set up kubeconfig if not already configured
    if ! sudo kubebuilder/bin/kubectl config current-context | grep -q "test-context"; then
        sudo kubebuilder/bin/kubectl config set-credentials test-user --token=1234567890
        sudo kubebuilder/bin/kubectl config set-cluster test-env --server=https://127.0.0.1:6443 --insecure-skip-tls-verify
        sudo kubebuilder/bin/kubectl config set-context test-context --cluster=test-env --user=test-user --namespace=default 
        sudo kubebuilder/bin/kubectl config use-context test-context
    fi
    # Configure containerd
    cat <<EOF | sudo tee /etc/containerd/config.toml
version = 3

[grpc]
  address = "/run/containerd/containerd.sock"

[plugins.'io.containerd.cri.v1.runtime']
  enable_selinux = false
  enable_unprivileged_ports = true
  enable_unprivileged_icmp = true
  device_ownership_from_security_context = false

[plugins.'io.containerd.cri.v1.images']
  snapshotter = "native"
  disable_snapshot_annotations = true

[plugins.'io.containerd.cri.v1.runtime'.cni]
  bin_dir = "/opt/cni/bin"
  conf_dir = "/etc/cni/net.d"

[plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc]
  runtime_type = "io.containerd.runc.v2"

[plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc.options]
  SystemdCgroup = false
EOF

    if ! is_running "containerd"; then
        echo "Starting containerd..."
        export PATH=$PATH:/opt/cni/bin:kubebuilder/bin
        sudo PATH=$PATH:/opt/cni/bin:/usr/sbin /opt/cni/bin/containerd -c /etc/containerd/config.toml &
    fi

    # Configure kubelet
    cat << EOF | sudo tee /var/lib/kubelet/config.yaml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
authentication:
  anonymous:
    enabled: true
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubelet/ca.crt"
authorization:
  mode: AlwaysAllow
clusterDomain: "cluster.local"
clusterDNS:
  - "10.0.0.10"
resolvConf: "/etc/resolv.conf"
runtimeRequestTimeout: "15m"
failSwapOn: false
seccompDefault: true
serverTLSBootstrap: false
containerRuntimeEndpoint: "unix:///run/containerd/containerd.sock"
staticPodPath: "/etc/kubernetes/manifests"
tlsCertFile: /var/lib/kubelet/pki/kubelet.crt
tlsPrivateKeyFile: /var/lib/kubelet/pki/kubelet.key
maxPods: 5
providerID: ""
EOF

    if ! is_running "kubelet"; then
        echo "Starting kubelet..."
        sudo PATH=$PATH:/opt/cni/bin:/usr/sbin kubebuilder/bin/kubelet \
            --kubeconfig=/var/lib/kubelet/kubeconfig \
            --config=/var/lib/kubelet/config.yaml \
            --root-dir=/var/lib/kubelet \
            --cert-dir=/var/lib/kubelet/pki \
           # --tls-cert-file=/var/lib/kubelet/pki/kubelet.crt \
           # --tls-private-key-file=/var/lib/kubelet/pki/kubelet.key \
            --hostname-override=$(hostname) \
           # --pod-infra-container-image=registry.k8s.io/pause:3.10 \
            --node-ip=$HOST_IP \
           # --cloud-provider=external \
           # --cgroup-driver=cgroupfs \
           # --max-pods=4  \
            --v=1 &
    fi

    # add alias k
    alias k='sudo kubebuilder/bin/kubectl'

    #move staticPod manifest
    sudo cp $(pwd)/manifests/*.yaml /etc/kubernetes/manifests/
}

stop() {
    echo "Stopping Kubernetes components..."
    stop_process "cloud-controller-manager"
    stop_process "gce_metadata_server"
    stop_process "kube-controller-manager"
    stop_process "kubelet"
    stop_process "kube-scheduler"
    stop_process "kube-apiserver"
    stop_process "containerd"
    stop_process "etcd"
    echo "All components stopped"

    #rm staticPod manifest
    sudo rm /etc/kubernetes/manifests/*
}

cleanup() {
    stop
    echo "Cleaning up..."
    sudo rm -rf ./etcd
    sudo rm -rf /var/lib/kubelet/*
    sudo rm -rf /run/containerd/*
    sudo rm -f /tmp/sa.key /tmp/sa.pub /tmp/token.csv /tmp/ca.key /tmp/ca.crt
    echo "Cleanup complete"
}

case "${1:-}" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    cleanup)
        cleanup
        ;;
    *)
        echo "Usage: $0 {start|stop|cleanup}"
        exit 1
        ;;
esac 