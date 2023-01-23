
python3 server.py --test &
PID=$!
python3 test.py

if [ $? -eq 0 ];
then
    kill $PID
    unset KUBECONFIG
    minikube start
    minikube addons enable ingress

    eval $(minikube -p minikube docker-env)


    echo "Docker Build"
    echo -e
    docker build -t vihar/athlete-server .
    echo -e


    echo -e
    echo "Docker Size"
    echo $(docker images | grep SIZE)
    echo $(docker images | grep vihar/athlete-server)
    echo -e

    echo -e
    kubectl apply -f deployment.yaml
    #kubectl expose deployment athlete-server-deploy --type=NodePort --port=80
    kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
    kubectl apply -f ingress.yaml
    echo -e

    echo -e
    echo "Waiting for Server to deploy"
    sleep 10

    echo -e
    echo -e
    echo "Testing the endpoint"
    curl $(minikube ip)/athlete
    echo -e
    echo -e

else
    kill $PID
    echo "Test Failed"
fi
