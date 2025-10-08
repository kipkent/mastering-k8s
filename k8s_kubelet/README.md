
Tasks:
**1. Beginner level**
#
- 4 manifests files in k8s_kubelet/manifests
- cd k8s_kubelet && bash kubelet.sh start
- kubectl create deployment nginx --image=nginx:latest --replicas=3

**2. Advanced level**
#
- cd k8s_kubelet && bash kubelet.sh start
- debug privileged container:
  kubectl debug node/codespaces-ca5b98 -it --image=verizondigital/kubectl-flame:v0.2.4-perf --profile=sysadmin -- sh

- profile kube-apiserver: collect samples from PID
  - get PID:
  - ps aux | grep kube-apiserver
  - cd /app && ./perf record -F 99 -p PID -g -o perf.data -- sleep 30
- build flame graph
  ./perf script -i perf.data | FlameGraph/stackcollapse-perf.pl > out.folded
  ./FlameGraph/flamegraph.pl out.folded > flame.svg

- Path of flame.svg
  k8s_kubelet/flame.svg
  




## additional commands
- add alias k
  alias k='sudo kubebuilder/bin/kubectl'

- pgrep containerd

## cli containerd
sudo /opt/cni/bin/ctr -n k8s.io c ls
sudo /opt/cni/bin/ctr -n k8s.io tasks ls

##
ps aux
ps -ef | grep 'etcd' | grep -v grep | awk '{print $2}' | xargs -r sudo kill -9
