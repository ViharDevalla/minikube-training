docker image rm vihar/athlete-server
unset KUBECONFIG
MINICHECK=$(minikube status | grep kubelet | awk '{ print $2}')
echo $MINICHECK
if [ $MINICHECK != "Running" ];
then
    minikube start
fi
kubectl delete deployment athlete-server-deploy
kubectl delete service athlete-service
kubectl delete ingress ingress-app
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
#minikube stop

