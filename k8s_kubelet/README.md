## add manifests pods to /etc/kubernetes/manifests

pgrep containerd

#cli containerd
sudo /opt/cni/bin/ctr -n k8s.io c ls
sudo /opt/cni/bin/ctr -n k8s.io tasks ls

##
ps aux
ps -ef | grep 'etcd' | grep -v grep | awk '{print $2}' | xargs -r sudo kill -9