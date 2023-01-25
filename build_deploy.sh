
#!/bin/bash

run_tests(){
    python3 docker-build/server.py --test &
    PID=$!
    python3 docker-build/test.py
}

start_minikube(){
    kill $PID
    unset KUBECONFIG
    MINICHECK=$(minikube status | grep kubelet | awk '{ print $2}')
    echo "Minikube Cluster is " $MINICHECK
    if [ $MINICHECK != "Running" ];
    then
        minikube start
        minikube addons enable ingress
    fi
}

build_docker(){
    eval $(minikube -p minikube docker-env)

    echo "Docker Build"
    docker build -t vihar/athlete-server docker-build/

    echo "Docker Size"
    echo $(docker images | grep SIZE)
    echo $(docker images | grep vihar/athlete-server)
}

start_cluster(){
    kubectl apply -f manifests/deployment.yaml
    kubectl apply -f manifests/service.yaml
    kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
    kubectl apply -f manifests/ingress.yaml
}

wait_for_deploy(){
    echo "Waiting for Server to deploy"
    until [ -n "$(kubectl get ingress ingress-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}' | awk -F '.' '{print $1}')" ]; do
        sleep 5
        echo "Checking if Ingress IP is assigned"
    done
}


test_endpoint(){
    echo "Testing the IP endpoint - 192.168.49.2/athlete"
    curl $(minikube ip)/athlete

    echo "Testing the nip.io endpoint - c0a83102.nip.io/athlete"
    curl c0a83102.nip.io/athlete
}


run_tests

if [ $? -eq 0 ];
then
    echo "Starting Minikube"
    start_minikube

    build_docker

    start_cluster

    wait_for_deploy

    test_endpoint

else
    kill $PID
    echo "Test Failed"
fi
