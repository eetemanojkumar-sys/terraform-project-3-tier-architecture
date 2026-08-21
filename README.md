# AWS 3-Tier Architecture — End-to-End DevOps Project

> **Flagship DevOps project:** provision a highly available AWS 3-tier architecture with Terraform, configure workloads with Ansible, automate delivery with Jenkins, containerize with Docker, deploy with Helm/Kubernetes, and verify the platform with health checks and monitoring.

![Architecture](assets/architecture.svg)

## Recruiter Snapshot

| Area | Implementation |
|---|---|
| Cloud | AWS — VPC, ALB, EC2, Auto Scaling, RDS, IAM, S3 |
| Infrastructure as Code | Terraform with reusable VPC, ALB, EC2 and RDS modules |
| Configuration | Ansible roles, templates and dynamic AWS inventory |
| CI/CD | Jenkins declarative pipeline using a Docker-based agent |
| Containers | Docker build, run and HTTP health verification |
| Deployment | Helm-managed Kubernetes deployment on Minikube |
| Reliability | Multi-AZ design, Auto Scaling, readiness/liveness probes, HPA |
| Observability | Prometheus, Grafana, Alertmanager, kube-state-metrics and Node Exporter |

## What This Project Demonstrates

This project connects infrastructure engineering and application delivery into one workflow instead of treating Terraform, Docker, Jenkins and Kubernetes as isolated exercises.

The workflow starts with version-controlled source code, validates infrastructure and configuration, builds and tests a container, validates a Helm chart, deploys to Kubernetes, checks workload health, and exposes the environment to monitoring.

```text
GitHub
  ↓
Jenkins CI/CD
  ├── Terraform validation
  ├── Ansible syntax validation
  ├── Docker build + application test
  └── Helm validation
          ↓
     Kubernetes deployment
          ↓
   Health verification
          ↓
Prometheus + Grafana
```

## Architecture

### AWS 3-Tier Infrastructure

- **Public tier:** Internet Gateway and Application Load Balancer across two Availability Zones.
- **Application tier:** EC2 instances in private subnets, managed through a Launch Template and Auto Scaling Group.
- **Database tier:** Amazon RDS MySQL in private database subnets.
- **Security:** tier-based Security Groups; the database is not directly exposed to the public internet.
- **State:** Terraform remote state is stored in Amazon S3 with encryption and state locking.

### Network Layout

| Tier | CIDR |
|---|---|
| VPC | `10.0.0.0/16` |
| Public Subnet 1 | `10.0.1.0/24` |
| Public Subnet 2 | `10.0.2.0/24` |
| Private App Subnet 1 | `10.0.11.0/24` |
| Private App Subnet 2 | `10.0.12.0/24` |
| Private DB Subnet 1 | `10.0.21.0/24` |
| Private DB Subnet 2 | `10.0.22.0/24` |

## CI/CD Pipeline

The Jenkins pipeline performs the following stages:

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

### Key Validation Commands

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate

ansible-playbook site.yml --syntax-check

helm lint three-tier-chart
helm template three-tier-app three-tier-chart
```

The container is tested against:

```text
GET /
GET /health
```

The Kubernetes deployment uses the `/health` endpoint for readiness and liveness probes.

## Technology Breakdown

### Terraform

Reusable modules provision:

```text
modules/
├── vpc/
├── alb/
├── ec2/
└── rds/
```

Key resources include VPC networking, route tables, NAT Gateway, ALB, target groups, Launch Template, Auto Scaling Group, RDS MySQL, IAM and Security Groups.

### Ansible

The Ansible layer handles host and application configuration, including Docker setup, application deployment, Nginx configuration, EFS-related configuration, templating and dynamic AWS EC2 inventory.

### Docker

The application is packaged as a Docker image. Jenkins creates build-specific and `latest` tags, starts a test container, verifies the HTTP endpoints, and cleans up the container.

### Kubernetes + Helm

The Helm chart manages:

- Deployment
- Service
- ConfigMap
- Secret
- Ingress
- Horizontal Pod Autoscaler
- Resource requests and limits
- Readiness and liveness probes

### Monitoring

The Kubernetes monitoring stack includes:

- Prometheus
- Grafana
- Alertmanager
- Prometheus Operator
- kube-state-metrics
- Node Exporter

## Project Structure

```text
terraform-project-3-tier-architecture/
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── backend.tf
├── Dockerfile
├── Jenkinsfile
├── app/
├── ansible/
├── modules/
│   ├── vpc/
│   ├── alb/
│   ├── ec2/
│   └── rds/
├── k8s/
├── three-tier-chart/
├── assets/
│   └── architecture.svg
└── screenshots/
```

## Quick Start

> Use your own AWS account configuration and never commit credentials or real secrets.

```bash
git clone https://github.com/eetemanojkumar-sys/terraform-project-3-tier-architecture.git
cd terraform-project-3-tier-architecture
```

### Terraform

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

### Ansible

```bash
cd ansible
ansible-playbook site.yml --syntax-check
ansible-playbook site.yml
```

### Docker

```bash
docker build -t three-tier-app:latest .
docker run -d --name three-tier-app -p 8080:8080 three-tier-app:latest
curl http://localhost:8080/health
```

### Helm and Kubernetes

```bash
helm lint three-tier-chart
helm upgrade --install three-tier-app three-tier-chart
kubectl get pods
kubectl get svc
kubectl get ingress
```

## Verification Evidence

The `screenshots/` directory is reserved for real execution evidence. Recommended captures:

1. Terraform provisioning or successful plan/apply
2. AWS infrastructure resources
3. Successful Jenkins pipeline
4. Docker application health check
5. Healthy Kubernetes Pods, Services and Ingress
6. Grafana or Prometheus monitoring dashboard

See [`screenshots/README.md`](screenshots/README.md) for the capture checklist and redaction guidance.

## Troubleshooting Experience

This project required debugging real infrastructure and CI/CD issues, including:

- Terraform undeclared-resource and syntax errors
- Ansible inventory and host-pattern issues
- Docker daemon socket permissions
- Jenkins Docker-agent package permissions
- Jenkins-to-Minikube networking and kubeconfig access
- Minikube cache and profile issues
- `kubectl` compatibility inside the Jenkins container
- Helm chart validation errors
- Kubernetes Service and NodePort verification
- Jenkinsfile Groovy syntax errors
- Docker port conflicts

These issues were resolved as part of getting the end-to-end pipeline working.

## Skills Demonstrated

**AWS:** VPC, ALB, EC2, Auto Scaling, RDS, IAM, S3, Security Groups, NAT Gateway  
**IaC:** Terraform, reusable modules, remote state  
**Configuration:** Ansible, dynamic inventory, Jinja2, Linux  
**CI/CD:** Jenkins, Docker-based agents, automated validation and deployment  
**Containers:** Docker, image tagging, container health checks  
**Kubernetes:** Deployments, Services, ConfigMaps, Secrets, Ingress, HPA, probes, Helm, Minikube  
**Monitoring:** Prometheus, Grafana, Alertmanager, kube-state-metrics, Node Exporter  
**Version Control:** Git, GitHub

## Outcome

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
Automated Testing
        ↓
Helm Packaging
        ↓
Kubernetes Deployment
        ↓
Health Verification
        ↓
Monitoring
```

The final pipeline successfully completed the end-to-end flow from Docker build and application testing through Helm deployment and Kubernetes health verification.

---

**Author:** Manoj Kumar  
**Focus:** DevOps & Cloud Engineering  
**Stack:** AWS | Terraform | Ansible | Jenkins | Docker | Kubernetes | Helm | Prometheus | Grafana | Linux | Git | GitHub
