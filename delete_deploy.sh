kubectl delete deployment athlete-server-deploy
kubectl delete service athlete-server-deploy
kubectl delete ingress ingress-app
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
