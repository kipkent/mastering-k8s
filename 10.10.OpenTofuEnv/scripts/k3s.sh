## K3S Bootstrap 
curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_ENABLE=true sh -
##
sudo k3s server --snapshotter native&
##
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml 
sudo chmod o+r /etc/rancher/k3s/k3s.yaml
##
alias k=kubectl
go install github.com/kubecolor/kubecolor@latest
alias kubectl=kubecolor
compdef kubecolor=kubectl
curl -sS https://webi.sh/k9s | sh
alias kk="EDITOR='code --wait' k9s"

## https://docs.fluentbit.io/manual/installation/kubernetes
helm repo add fluent https://fluent.github.io/helm-charts
helm upgrade --install fluent-bit fluent/fluent-bit
