# Simple Scalable API - Using Docker, MiniKube with Ingress


Building a Simple Scalable API using Python, containerizing it using Docker and Deploying it using Minikube (kubectl) with Ingress

Table of contents
=================
- [Simple Scalable API - Using Docker, MiniKube with Ingress](#simple-scalable-api---using-docker-minikube-with-ingress)
- [Table of contents](#table-of-contents)
- [Dependencies](#dependencies)
- [Installation](#installation)
- [Server](#server)
  - [Objective](#objective)
  - [Building a Server](#building-a-server)
  - [Tests](#tests)
- [Docker](#docker)
- [Minikube](#minikube)
- [Build Deploy Script](#build-deploy-script)



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

## Objective
A Simple HTTP Server which returns a static JSON key value of myFavoriteAthlete when a GET request is called

## Building a Server

File: `server.py`

The idea is to create a minimal GET API with little to no dependency. So, I choose **Python** as the language for the server and used its inbuilt modules to serve GET requests.

Inbuilt modules used : `http` and `json`

No additional modules have been used.


## Tests
File: `test.py`

Testing is necessary to check the working of the application and solve errors in case of failures in deployment.

Testing module used: `unittest` (inbuilt)

I built 4 testcases to check the **Function** and **Server Hosting**

Functions has 2 tests - one to check working of the function, other to mock the function and check the error handling

API Server has 2 tests, one to test success and other to check 404 response of other endpounts

# Docker
Now that the


# Minikube


Linux (manual installation)
```bash
$ git clone https://github.com/ViharDevalla/minikube-training
$ chmod +x build_deploy.sh
```

# Build Deploy Script


Linux (manual installation)
```bash
$ git clone https://github.com/ViharDevalla/minikube-training
$ chmod +x build_deploy.sh
```