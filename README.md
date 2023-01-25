# Simple Scalable API - Using Docker, MiniKube with Ingress


Building a Simple Scalable API using Python, containerizing it using Docker and Deploying it using Minikube (kubectl) with Ingress

Table of contents
=================
- [Simple Scalable API - Using Docker, MiniKube with Ingress](#simple-scalable-api---using-docker-minikube-with-ingress)
- [Table of contents](#table-of-contents)
- [Dependencies](#dependencies)
- [Installation](#installation)
- [Server](#server)
  - [Building a Server](#building-a-server)
  - [Tests](#tests)
- [Docker](#docker)
- [Minikube](#minikube)
  - [Docker inside Minikube](#docker-inside-minikube)
  - [Deployment and Ingress Manifests](#deployment-and-ingress-manifests)
- [Build Deploy Script](#build-deploy-script)
- [Miscelleneous Bugs and Fixes](#miscelleneous-bugs-and-fixes)



# Dependencies

- Running on `Linux`
- `minikube` and `kubectl` installed
- `Ingress` Extension installed
- (Optional) `sudo` perms to change host name



# Installation


```bash
$ git clone https://github.com/ViharDevalla/minikube-training
$ chmod +x build_deploy.sh
```

# Server

The objective is to build a Simple HTTP Server which returns a static JSON key value of myFavoriteAthlete when a GET request is called

## Building a Server

File: `server.py`

The idea is to create a minimal GET API with little to no dependency. So, I choose **Python** as the language for the server and used its inbuilt modules to serve GET requests.

Inbuilt modules used : `http`, `json`,`os`and `sys`

`sys` has been used to create a test mode for the server to be hosted on a different port for testing.

`os` has been used to get the PID of the app incase we want to terminate the test/prod process.

`json` has been used o convert Python dict to JSON output sent as response

`http.server`
This module is packaged within Python and is easily accessible to start a **SimpleHTTPServer**.

*P.S. It can be used to host file directory for quick file transfer using `python3 -m http.server`*

**Resource for Web Hosting**:
- [OOTB Python Web Hosting](https://pythonbasics.org/webserver/)
- [Difference b/w 127.0.0.1, localhost, 0.0.0.0](https://stackoverflow.com/questions/20778771/what-is-the-difference-between-0-0-0-0-127-0-0-1-and-localhost)




## Tests
File: `test.py`

Testing is necessary to check the working of the application and solve errors in case of failures in deployment.

Testing module used: `unittest` (inbuilt)

I built 4 testcases to check the **Function** and **Server Hosting**

Functions has 2 tests - one to check working of the function, other to mock the function and check the error handling

API Server has 2 tests, one to test success and other to check 404 response of other endpounts

**Resources**:
[Intro to Mocking in Python](https://www.toptal.com/python/an-introduction-to-mocking-in-python)

# Docker
Now that the Server code is ready for deploy. The next step is containerizing it. Choosing a good base image is vital for the size of the image and the operations that can be done inside image.

After comparing the sizes of the Python Docker Images by tags in [DockerHub](https://hub.docker.com/_/python/tags), it is seen that the **Alpine Image** is the smallest at **48MB**.

Read More about why Alpine Images arent the best image for Python [here](https://pythonspeed.com/articles/base-image-python-docker-images/#:~:text=Why%20you%20shouldn't%20use,I%20recommend%20against%20using%20Alpine.) and [here](https://pythonspeed.com/articles/alpine-docker-python/)

But in my case, I have **zero dependencies** which allows me to use the Alpine build with no issues.

*P.S. In case of dependencies, the better Python Image for Docker could be  `slim-bullseye` (**128MB**)*

Also the python server runs using a non-root user called **"worker"** instead of the usual root user. This could prevent security flaws like the [2019 RunC Bug](https://www.sdxcentral.com/articles/news/kubernetes-docker-containerd-impacted-by-runc-container-runtime-bug/2019/02/) from being re-engineered.

Resources:
[Making Small Docker Images](https://towardsdatascience.com/slimming-down-your-docker-images-275f0ca9337e)

# Minikube

Install Minikube from their site [here](https://minikube.sigs.k8s.io/docs/start/)


Minikube on default installation checks for **KUBECONFIG** env to restore or use the existing kubeconfig.
This can be changed by either `unset KUBECONFIG` or exporting a different path using `export KUBECONFIG <newPath>`.

This can be made persistant using `.bashrc` or other ways to change env.

*P.S. List all the running resources in MiniKube using*
```bash
for i in `kubectl api-resources | awk '{print $1}'`; do kubectl get $i; done
```

*P.S. We can get the status of MiniKube using ` minikube status ` to confirm if Minikube is running or not*

## Docker inside Minikube
Since, this project requires a Private Docker image as the container for the pods, we need to export the docker-env to access the local docker registry.

This can be done by `eval $(minikube -p minikube docker-env)`

**The Docker build must happen after this step, else the image will not be recognised by minikube**

## Deployment and Ingress Manifests
`deployment.yaml` has the manifest to deploy the server using the container. Current manifest uses *1* replica and opens port 80 for access to the container webserver.

*P.S. Dont forget to expose the deployment port using services*

`ingress.yaml` has the manifest for the **NGINX Ingress Controller** which is used as the **reverse proxy** and the **load balancer** to the server we have deployed. This combined with the Deployment allows for good scaling for the server



*P.S. The current manifest allows all hosts to access the server using the Ingress IP (**minikube ip** in this case). This can be changed by adding a particular host in manifest and configuring the /etc/hosts file with sude perms*


*P.S. Make sure NGINX Ingress Controller is up to date, it is a known attack vector with multiple vulnerabilities in the past.

**Resources**
- [CVE Link](https://support.f5.com/csp/article/K52125139#:~:text=This%20vulnerability%20may%20allow%20an,all%20secrets%20in%20the%20cluster.)
- [Related Article](https://lab.wallarm.com/two-critical-security-flaws-found-in-nginx-ingress-controller/)



# Build Deploy Script

A build script `build_deploy.sh` using bash has been configured to run all the docker and kubectl commands.

This is the entrypoint to the entire project.

**If you want to serve the Ingress on a specific host name:**
1. Uncomment the  line containing `- host:` in `ingress.yaml` and change the host name to the appropriate name
2. Manually add the hostname and IP (`minikube ip` in case of local deploy) to the `/etc/hosts` file



*P.S. `delete_deploy.sh` has also been created to delete the Deployment, Service and Ingress services.*

# Miscelleneous Bugs and Fixes
###Docker Context Matters
Remember to connect Minikube to docker daemon i.e. `eval $(minikube -p minikube docker-env)` **before** building the image as MiniKube only gets context and cannot access the registry details set before the `eval`.

###MiniKube IP Errors
IP not accessible from the host machine. This can be fixed by adding the IP to the /etc/hosts file


###Ingress IP Errors
IP not accessible from the host machine. One possible error is Ingress Controller Failing (due to it not being availabe or active).
- **Possible Fix** : [Stack Overflow Link](https://stackoverflow.com/questions/69932480/minikube-ingress-stuck-in-scheduled-for-sync)

###ClusterIP / NodePort / LoadBalancer / Ingress

These services allow the deployment to be accessed.
[Source](https://medium.com/google-cloud/kubernetes-nodeport-vs-loadbalancer-vs-ingress-when-should-i-use-what-922f010849e0)

- **ClusterIP** is the default service which doesnt expose any port externally (only traffic from Kubernetes / Kubernetes Proxy allowed).
- **NodePort** is the primitive way to expose a **one service per port**. You can only use ports 30000–32767.
- **LoadBalancer** is the standard way to expose a service to the internet. But each service will have seperate Load Balancer IP.
- **Ingress** is the router in front of all services (and ClusterIP/NodePort) which can expose **multiple services on same IP**

