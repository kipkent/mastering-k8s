
mkdir ~/.kube
sudo kubebuilder/bin/kubectl config view > ~/.kube/config

go mod init newresource-controller
# Build the controller
go mod tidy
go build -o bin/manager main.go

# Install CRD
sudo kubectl apply -f config/crd/bases/apps.newresource.com_newresources.yaml

# Run the controller
sudo ./bin/manager

# Test the Controller
Create a test resource:

cat <<EOF | kubectl apply -f -
apiVersion: apps.newresource.com/v1alpha1
kind: NewResource
metadata:
  name: test-resource
spec:
  foo: "bob world"
EOF

# Verify the controller is working:
kubectl get newresource
kubectl get newresource test-resource -o yaml
You should see status.ready: true in the output.

# metrics
curl http://localhost:8080/metrics