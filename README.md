# AWS 3-Tier Architecture — End-to-End DevOps Project

## Project Overview

This project implements an end-to-end **AWS 3-tier architecture and DevOps delivery pipeline**.

The infrastructure is provisioned with **Terraform**, configured with **Ansible**, containerized with **Docker**, automated with **Jenkins**, deployed to **Kubernetes using Helm**, and monitored with **Prometheus and Grafana**.

The project was developed and tested in the **AWS Mumbai Region (`ap-south-1`)**.

The goal is to demonstrate a realistic DevOps workflow from infrastructure provisioning through application delivery, Kubernetes deployment, verification, and monitoring.

---

## End-to-End DevOps Flow

```text
Developer
   |
   v
GitHub Repository
   |
   v
Jenkins CI/CD
   |
   +--------------------+
   |                    |
   v                    v
Terraform            Ansible
   |                    |
   +---------+----------+
             |
             v
        AWS Infrastructure
             |
             v
          Docker
             |
             v
       Docker Image Build
             |
             v
       Docker Application Test
             |
             v
        Helm Validation
             |
             v
          Minikube
             |
             v
       Helm Deployment
             |
             v
        Kubernetes
             |
             v
     Application Health Check
             |
             v
   Prometheus + Grafana
```

---

# Architecture

```text
                         Internet
                            |
                            v
                    Internet Gateway
                            |
                            v
              Application Load Balancer
                  Public Subnets
                 /              \
                /                \
        ap-south-1a          ap-south-1b
                \                /
                 \              /
                  Auto Scaling Group
                         |
                  EC2 Application Tier
                   Private Subnets
                         |
                         v
                    Amazon RDS
                      MySQL
                Private DB Subnets

                       |
                       | DevOps Delivery
                       v
                 Jenkins CI/CD
                       |
                       v
                    Docker
                       |
                       v
                   Minikube
                       |
                       v
                   Kubernetes
                       |
                       v
                      Helm
                       |
                       v
              Prometheus + Grafana
```

---

# AWS Infrastructure

Terraform provisions the main AWS infrastructure using reusable modules.

## AWS Services

- Amazon VPC
- Public and Private Subnets
- Internet Gateway
- NAT Gateway
- Route Tables
- Application Load Balancer
- Target Groups
- Amazon EC2
- Launch Templates
- Auto Scaling Group
- Amazon RDS MySQL
- Security Groups
- Amazon S3
- AWS IAM

## Network CIDR

```text
VPC: 10.0.0.0/16
```

| Tier | CIDR |
|---|---|
| Public Subnet 1 | `10.0.1.0/24` |
| Public Subnet 2 | `10.0.2.0/24` |
| Private App Subnet 1 | `10.0.11.0/24` |
| Private App Subnet 2 | `10.0.12.0/24` |
| Private DB Subnet 1 | `10.0.21.0/24` |
| Private DB Subnet 2 | `10.0.22.0/24` |

The infrastructure is distributed across multiple Availability Zones for high availability.

---

# Terraform

Terraform is used as the Infrastructure as Code layer.

## Terraform Modules

```text
modules/
├── vpc/
├── alb/
├── ec2/
└── rds/
```

### VPC Module

Creates:

- VPC
- Public subnets
- Private application subnets
- Private database subnets
- Internet Gateway
- NAT Gateway
- Route tables
- Route associations

### ALB Module

Creates:

- Application Load Balancer
- ALB security group
- Target group
- HTTP listener

### EC2 Module

Creates:

- EC2 security group
- Launch template
- Auto Scaling Group
- Target group integration
- IAM configuration

### RDS Module

Creates:

- RDS MySQL instance
- DB subnet group
- RDS security group
- Private database tier

---

# Terraform Remote State

Terraform state is stored remotely using Amazon S3.

```hcl
terraform {
  backend "s3" {
    bucket       = "manoj-terraform-state-2026-710959681253-ap-south-1-an"
    key          = "3-tier/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

Remote state provides:

- Centralized state management
- State persistence
- Encryption
- State locking
- Better collaboration support

AWS credentials are not hard-coded in Terraform. The deployment uses an IAM role attached to the management EC2 instance.

---

# Ansible Configuration Management

Ansible configures the application and web tiers after infrastructure provisioning.

The repository contains:

```text
ansible/
├── ansible.cfg
├── site.yml
├── group_vars/
├── inventory/
├── requirements.yml
├── roles/
│   ├── app/
│   ├── common/
│   ├── efs/
│   └── web/
└── scripts/
```

Ansible responsibilities include:

- Common host configuration
- Docker installation/configuration
- Application container deployment
- Nginx installation and configuration
- Web-tier configuration
- EFS-related configuration
- Application configuration templating
- Dynamic AWS EC2 inventory

---

# Application

The project includes a lightweight Python HTTP application used for container and Kubernetes validation.

The application exposes:

```text
GET /
GET /health
```

Expected responses:

```text
/
Three Tier Application
```

```text
/health
OK
```

The `/health` endpoint is used by Kubernetes readiness and liveness probes.

---

# Docker

The application is containerized using Docker.

Example image:

```text
three-tier-app:<BUILD_NUMBER>
```

The Jenkins pipeline creates both a build-specific tag and a `latest` tag.

Docker validation includes:

- Image build
- Container startup
- Application health verification
- Root endpoint verification
- Container cleanup

---

# Jenkins CI/CD Pipeline

Jenkins provides the automated CI/CD workflow.

The pipeline uses a Docker-based Jenkins agent and performs the following stages:

```text
Environment Check
        ↓
Checkout
        ↓
Install CI Tools
        ↓
Terraform Validation
        ↓
Ansible Validation
        ↓
Docker Check
        ↓
Docker Build
        ↓
Docker Test
        ↓
Helm Validation
        ↓
Load Image into Minikube
        ↓
Helm Deploy
        ↓
Kubernetes Verification
        ↓
Application Health Check
```

## Terraform CI Validation

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

## Ansible CI Validation

```bash
ansible-playbook site.yml --syntax-check
```

## Docker CI Validation

The pipeline builds the application image and runs a real container test against the application endpoints.

## Helm CI Validation

The pipeline validates the Helm chart with:

```bash
helm lint three-tier-chart
helm template three-tier-app three-tier-chart
```

## Kubernetes CD

The pipeline loads the application image into Minikube and deploys it using Helm.

The deployment is verified using:

```bash
kubectl get pods
kubectl get svc
kubectl get ingress
```

The pipeline also waits for Kubernetes resources to become healthy and performs an application health check.

---

# Kubernetes and Helm

The repository contains Kubernetes manifests and a Helm chart.

```text
three-tier-chart/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── _helpers.tpl
    ├── configmap.yaml
    ├── deployment.yaml
    ├── hpa.yaml
    ├── ingress.yaml
    ├── secret.yaml
    └── service.yaml
```

The Helm chart manages:

- Deployment
- Service
- ConfigMap
- Secret
- Ingress
- Horizontal Pod Autoscaler
- Health probes
- Resource requests and limits

Example application configuration:

```yaml
replicaCount: 2

service:
  type: NodePort
  port: 80
  targetPort: 8080

containerPort: 8080
```

The Kubernetes application uses HTTP readiness and liveness probes against `/health`.

---

# Kubernetes Deployment Validation

The application was successfully deployed to Minikube and verified using Kubernetes commands.

Typical verification:

```bash
kubectl get pods
kubectl get svc
kubectl get ingress
```

Example application test:

```bash
curl http://<MINIKUBE-IP>:<NODEPORT>/
```

Expected response:

```text
Three Tier Application
```

Health endpoint:

```bash
curl http://<MINIKUBE-IP>:<NODEPORT>/health
```

Expected:

```text
OK
```

---

# Monitoring

The Kubernetes environment was integrated with the Prometheus and Grafana monitoring stack.

Components include:

- Prometheus
- Grafana
- Alertmanager
- Prometheus Operator
- kube-state-metrics
- Node Exporter

Monitoring services were deployed in the `monitoring` namespace.

Example:

```bash
kubectl get svc -n monitoring
```

This provides visibility into Kubernetes workloads, nodes, cluster resources, and application infrastructure.

---

# High Availability

The AWS architecture uses multiple Availability Zones.

Example Auto Scaling configuration:

```text
Minimum instances: 2
Desired instances: 2
Maximum instances: 4
```

The Application Load Balancer distributes traffic across application instances managed by the Auto Scaling Group.

---

# Security Architecture

The infrastructure follows tier-based security:

```text
Internet
   |
   | HTTP
   v
ALB Security Group
   |
   v
EC2 Security Group
   |
   | MySQL
   v
RDS Security Group
```

The database tier is private and is not directly exposed to the internet.

The RDS security group accepts database traffic from the application tier rather than from the public internet.

AWS credentials are not hard-coded in source code.

---

# Project Structure

```text
terraform-project-3-tier-architecture/
│
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── backend.tf
├── terraform.tfvars.example
├── Dockerfile
├── .dockerignore
├── Jenkinsfile
├── README.md
│
├── app/
│   ├── Dockerfile
│   └── health.py
│
├── ansible/
│   ├── ansible.cfg
│   ├── site.yml
│   ├── group_vars/
│   ├── inventory/
│   ├── scripts/
│   └── roles/
│
├── modules/
│   ├── vpc/
│   ├── alb/
│   ├── ec2/
│   └── rds/
│
├── k8s/
│   ├── deployment.yml
│   └── service.yml
│
└── three-tier-chart/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
```

---

# Deployment Commands

## Clone

```bash
git clone https://github.com/eetemanojkumar-sys/terraform-project-3-tier-architecture.git
cd terraform-project-3-tier-architecture
```

## Terraform

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

## Ansible

```bash
cd ansible
ansible-playbook site.yml --syntax-check
ansible-playbook site.yml
```

## Docker

```bash
docker build -t three-tier-app:latest .
docker run -d --name three-tier-app -p 8080:8080 three-tier-app:latest
curl http://localhost:8080/health
```

## Helm

```bash
helm lint three-tier-chart
helm template three-tier-app three-tier-chart
helm upgrade --install three-tier-app three-tier-chart
```

## Kubernetes

```bash
kubectl get pods
kubectl get svc
kubectl get ingress
```

## Monitoring

```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring
```

---

# Troubleshooting Experience

During development, the project was debugged through several real CI/CD and infrastructure issues, including:

- Terraform undeclared resource and syntax errors
- Ansible inventory and host-pattern issues
- Docker daemon socket permission problems
- Jenkins Docker-agent package installation permissions
- Jenkins Docker-agent to Minikube networking
- Minikube profile and kubeconfig access
- Minikube read-only cache permissions
- Snap-based `kubectl` incompatibility inside the Jenkins container
- Helm chart validation errors
- Kubernetes service and NodePort verification
- Jenkinsfile Groovy brace/syntax errors
- Docker port conflicts

The final Jenkins pipeline successfully completed the complete CI/CD flow from Docker build and testing through Helm deployment and Kubernetes application health verification.

---

# Skills Demonstrated

### Cloud & Infrastructure

- AWS
- Terraform
- Terraform Modules
- VPC Networking
- Multi-AZ Architecture
- ALB
- EC2
- Auto Scaling
- RDS
- IAM
- S3 Remote State
- Security Groups
- NAT Gateway

### Configuration Management

- Ansible
- Dynamic AWS Inventory
- Jinja2 Templates
- Linux Administration

### Containers

- Docker
- Docker Images
- Docker Containers
- Container Health Checks

### CI/CD

- Jenkins
- Declarative Pipeline
- Docker-based Jenkins Agents
- Automated Validation
- Automated Deployment
- Build-specific Image Tagging

### Kubernetes

- Kubernetes
- Minikube
- Deployments
- Services
- ConfigMaps
- Secrets
- Ingress
- Horizontal Pod Autoscaling
- Readiness Probes
- Liveness Probes
- Helm

### Monitoring

- Prometheus
- Grafana
- Alertmanager
- kube-state-metrics
- Node Exporter

### Version Control

- Git
- GitHub

---

# Project Outcome

The project demonstrates a complete DevOps lifecycle:

```text
Infrastructure as Code
        ↓
Configuration Management
        ↓
Containerization
        ↓
Continuous Integration
        ↓
Helm Packaging
        ↓
Kubernetes Deployment
        ↓
Automated Verification
        ↓
Monitoring
```

The final CI/CD pipeline was successfully executed end-to-end.

---

# Author

**Manoj Kumar**

Cloud & DevOps

**Technologies:** AWS | Terraform | Ansible | Jenkins | Docker | Kubernetes | Helm | Prometheus | Grafana | Linux | Git | GitHub