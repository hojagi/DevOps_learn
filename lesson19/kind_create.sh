#! /bin/env bash
export DOCKER_HOST_IP="10.168.2.234"
#export DOCKER_HOST_EXTERNAL_IP="37.194.189.99"
export POD_SUBNET="10.240.0.0/16"
export SERVICE_SUBNET="10.0.0.0/16"

# create kind cluster
envsubst < config.yml | kind create cluster --config=-

# # add external ip docker-machine into kubeconfig
#echo "Edit kube config file..."
#sed -i "s/$DOCKER_HOST_IP/$DOCKER_HOST_EXTERNAL_IP/g" ~/.kube/config

# # get kubernetes cluster info
# kubectl --insecure-skip-tls-verify cluster-info

# install Nginx ingress controller
echo "Install Ingress NGINX..."
kubectl --insecure-skip-tls-verify apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# install Calico
echo "Install Calico CNI..."
kubectl --insecure-skip-tls-verify apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
watch kubectl --insecure-skip-tls-verify get pods -l k8s-app=calico-node -A