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

Inbuilt modules used : `http` and `json`

Resource for Web Hosting:
[OOTB Python Web Hosting](https://pythonbasics.org/webserver/)
[Difference b/w 127.0.0.1,localhost,0.0.0.0](https://stackoverflow.com/questions/20778771/what-is-the-difference-between-0-0-0-0-127-0-0-1-and-localhost)

`http.server`
This module is packaged within Python and is easily accessible to start a **SimpleHTTPServer**.

*P.S. It can be used to host file directory for quick file transfer using `python3 -m http.server`*




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

## Docker inside Minikube
Since, this project requires a Private Docker image as the container for the pods, we need to export the docker-env to access the local docker registry.

This can be done by `eval $(minikube -p minikube docker-env)`

## Deployment and Ingress Manifests
`deployment.yaml` has the manifest to deploy the server using the container. Current manifest uses *1* replica and opens port 80 for access to the container webserver.

*P.S. Dont forget to expose the deployment throught the node port for the Ingress Setup later*

`ingress.yaml` has the manifest for the **NGINX Ingress Controller** which is used as the **reverse proxy** and the **load balancer** to the server we have deployed. This combined with the Deployment allows for good scaling for the server



*P.S. The current manifest allows all hosts to access the server using the Ingress IP (**minikube ip** in this case). This can be changed by adding a particular host in manifest and configuring the /etc/hosts file with sude perms*



# Build Deploy Script

A build script `build_deploy.sh` using bash has been configured to run all the docker and kubectl commands.

This is the entrypoint to the entire project.

**If you want to serve the Ingress on a specific host name:**
1. Uncomment the last line in `ingress.yaml` and change the host name to the appropriate name
2. Manually add the hostname and IP (`minikube ip` in case of local deploy) to the /etc/hosts file



*P.S. `delete_deploy.sh` has also been created to delete the Deployment, Service and Ingress services.*

# Miscelleneous Bugs and Fixes
- **Docker Context Matters** : Remember to connect Minikube to docker daemon i.e. `eval $(minikube -p minikube docker-env)` **before** building the image as MiniKube only gets context and cannot access the registry details set before the `eval`.
- **MiniKube IP** is not accessible from the host machine. This can be fixed by adding the IP to the /etc/hosts file
- **Ingress IP** is not accessible from the host machine. One possible error is Ingress Controller Failing **Fix** : https://stackoverflow.com/questions/69932480/minikube-ingress-stuck-in-scheduled-for-sync
