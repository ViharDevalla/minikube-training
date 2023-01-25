
python3 docker-build/server.py --test &
PID=$!
python3 docker-build/test.py

if [ $? -eq 0 ];
then
    kill $PID
    unset KUBECONFIG
    MINICHECK=$(minikube status | grep kubelet | awk '{ print $2}')
    echo $MINICHECK
    if [ $MINICHECK != "Running" ];
    then
        minikube start
        minikube addons enable ingress
    fi


    eval $(minikube -p minikube docker-env)


    echo "Docker Build"
    echo -e
    docker build -t vihar/athlete-server docker-build/
    echo -e


    echo -e
    echo "Docker Size"
    echo $(docker images | grep SIZE)
    echo $(docker images | grep vihar/athlete-server)
    echo -e

    echo -e
    kubectl apply -f manifests/deployment.yaml
    kubectl apply -f manifests/service.yaml
    kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
    kubectl apply -f manifests/ingress.yaml
    echo -e

    echo -e
    echo "Waiting for Server to deploy"
    sleep 10

    echo -e
    echo -e
    echo "Testing the IP endpoint - 192.168.49.2/athlete"
    curl $(minikube ip)/athlete
    echo -e
    echo "Testing the nip.io endpoint - c0a83102.nip.io/athlete"
    curl c0a83102.nip.io/athlete
    echo -e
    echo -e

else
    kill $PID
    echo "Test Failed"
fi
