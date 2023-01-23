docker image rm vihar/athlete-server
unset KUBECONFIG
minikube start
kubectl delete deployment athlete-server-deploy
kubectl delete service athlete-service
kubectl delete ingress ingress-app
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
minikube stop
