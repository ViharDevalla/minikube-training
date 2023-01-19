docker build -t athlete-server .
unset KUBECONFIG
minikube start
minikube addons enable ingress
eval $(minikube -p minikube docker-env)
kubectl apply -f deployment.yaml
kubectl expose deployment athlete-server-deploy --type=NodePort --port=80
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
kubectl apply -f ingress.yaml
