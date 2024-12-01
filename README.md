# Microservice Deployment on Kubernetes

This repository contains all the necessary code and configurations to deploy a Python-based microservice on a Kubernetes (K8s) cluster hosted on AWS using Terraform for infrastructure provisioning and GitHub Actions for CI/CD.

## Overview
The project automates:
- **Containerization**: Builds and pushes a Docker image for the microservice.
- **Infrastructure Provisioning**: Creates AWS resources such as VPC, EKS, and subnets using Terraform.
- **Microservice Deployment**: Deploys the microservice to the Kubernetes cluster and exposes it using a LoadBalancer.

---

## Project Components

### 1. **Infrastructure Configuration**
- **Terraform Files**
  - `main.tf`: Defines AWS resources (VPC, subnets, security groups, EKS cluster, and node group).
  - `variables.tf`: Contains variable definitions for flexible infrastructure configuration.
  - `terraform.tfvars`: Provides default values for Terraform variables.
  - `outputs.tf`: Exposes resource outputs for debugging and validation.
  
### 2. **Microservice Docker Image**
- **Dockerfile**
  - Defines the Python runtime and installs required dependencies for the microservice.

### 3. **Kubernetes Configuration**
- **`deployment.yml`**
  - Defines the deployment specifications for the microservice, including replicas and container details.
- **`service.yml`**
  - Configures a LoadBalancer service to expose the microservice.

### 4. **CI/CD Pipeline**
- **GitHub Actions Workflow (`workflow.yml`)**
  - Automates the build, provisioning, and deployment process.

---

## Setup and Deployment Guide

### Prerequisites
1. **AWS Account**: For provisioning resources.
2. **Docker Hub Account**: To store the Docker image.
3. **GitHub Repository**: To manage source code and workflows.
4. **Terraform CLI**: For infrastructure provisioning.
5. **kubectl**: For managing the Kubernetes cluster.

### Steps to Deploy

#### 1. Clone the Repository

git clone <repository-url>

===================================================================================

2. Configure Environment Variables
Set the following GitHub repository secrets:
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
DOCKERHUB_USERNAME
DOCKERHUB_PASSWORD
3. Containerize the Microservice
Build and test the Docker image:

docker build -t <dockerhub-username>/micro-app:<tag> .
docker run -p 5000:5000 <dockerhub-username>/micro-app:<tag>

===================================================================================
4. Provision the Infrastructure
Initialize and deploy Terraform configuration:

terraform init
terraform apply -auto-approve


===================================================================================
5. Deploy Microservice to Kubernetes
Apply Kubernetes manifests:

kubectl apply -f deployment.yml
kubectl apply -f service.yml


6. Verify Deployment
Check the status of pods and services:

kubectl get pods
kubectl get svc
==================================================================================

CI/CD Workflow Details
The workflow.yml automates the following:

Containerization Job:
Builds and pushes the Docker image to Docker Hub.
Tests the Docker image locally.
Terraform Job:
Provisions or destroys AWS infrastructure based on inputs.
Deployment Job:
Updates kubeconfig to interact with the EKS cluster.
Deploys Kubernetes manifests for the microservice.
Triggering the Workflow
Push to main branch: Automatically triggers the workflow.
Manual trigger: Allows destruction of resources via workflow_dispatch


Outputs and Access
After deployment, retrieve the service's external URL:

kubectl get svc microservice-service
====================================================================================

Kubernetes Deployment Files
deployment.yml
Purpose: Deploys the Python microservice application as pods in the Kubernetes cluster.
Key Sections:

Kind: Specifies the type of resource (Deployment) for managing pods.
Metadata:
name: The name of the deployment (microservice).
Spec:
replicas: Number of pods to be deployed (2).
selector: Ensures that the deployment manages pods with the label app: microservice.
template: Defines the pod template:
Labels: Assigns the app: microservice label.
Containers: Defines the container details:
name: Container name.
image: Docker image used for the container.
ports: Exposes container port 5000

--------------------------------------------------

service.yml
Purpose: Exposes the microservice pods to external traffic using a LoadBalancer.
Key Sections:

Kind: Specifies the type of resource (Service).
Metadata:
name: The name of the service (microservice-service).
Spec:
Selector: Maps the service to pods with the label app: microservice.
Ports:
port: Port exposed by the service (80).
targetPort: Port on which the container is running (5000).
Type: LoadBalancer to expose the service to external traffic.

==============================================================================
Terraform Files
main.tf
Purpose: Defines the infrastructure resources for the AWS environment, including VPC, subnets, security groups, and the EKS cluster.
Key Sections:

VPC and Subnets:
Creates a VPC with a CIDR block defined in terraform.tfvars.
Defines two public subnets.
Internet Gateway and Route Table:
Configures internet connectivity for the VPC.
Security Groups:
Allows inbound traffic on ports 5000 (application), 22 (SSH), and 443 (HTTPS).
EKS Cluster:
Sets up the EKS cluster with the required IAM roles and policies.
Creates a node group with EC2 instances for worker nodes



terraform.tfvars
Purpose: Provides actual values for variables defined in variables.tf

region              = "us-west-2"
vpc_cidr            = "10.0.0.0/16"
public_key_path     = "id_rsa.pub"
cluster_name        = "stage-eks-cluster"
node_desired_capacity = 2
