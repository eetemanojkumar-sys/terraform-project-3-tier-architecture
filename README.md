# AWS 3-Tier Architecture with Terraform

## Project Overview

This project provisions a highly available **3-tier architecture on AWS using Terraform**.

The infrastructure is built using reusable Terraform modules and includes networking, load balancing, Auto Scaling, a private database tier, security groups, and remote Terraform state management.

The project was deployed and tested in the **AWS Mumbai Region (`ap-south-1`)**.

---

## Architecture

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
```

---

## AWS Services Used

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

---

## Network Architecture

The infrastructure uses a VPC with the following CIDR:

```text
10.0.0.0/16
```

Subnets:

| Tier | CIDR |
|---|---|
| Public Subnet 1 | `10.0.1.0/24` |
| Public Subnet 2 | `10.0.2.0/24` |
| Private App Subnet 1 | `10.0.11.0/24` |
| Private App Subnet 2 | `10.0.12.0/24` |
| Private DB Subnet 1 | `10.0.21.0/24` |
| Private DB Subnet 2 | `10.0.22.0/24` |

Resources are distributed across multiple Availability Zones.

---

## Terraform Project Structure

```text
terraform-project-3-tier-architecture/
│
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── backend.tf
├── terraform.tfvars.example
├── .terraform.lock.hcl
├── .gitignore
│
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── alb/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── rds/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## Terraform Modules

### VPC Module

Responsible for:

- VPC
- Public subnets
- Private application subnets
- Private database subnets
- Internet Gateway
- NAT Gateway
- Route tables
- Route table associations

### ALB Module

Responsible for:

- Application Load Balancer
- ALB Security Group
- Target Group
- HTTP Listener

### EC2 Module

Responsible for:

- EC2 Security Group
- Launch Template
- Auto Scaling Group
- Target Group integration

### RDS Module

Responsible for:

- RDS MySQL instance
- DB Subnet Group
- RDS Security Group
- Database isolation

---

## High Availability

The architecture uses multiple Availability Zones.

The Application Load Balancer distributes incoming traffic between application instances managed by an Auto Scaling Group.

Example Auto Scaling configuration:

```text
Minimum instances: 2
Desired instances: 2
Maximum instances: 4
```

---

## Security

The architecture follows tier-based security.

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

The database is not directly exposed to the internet.

The RDS Security Group accepts database traffic from the application-tier Security Group.

AWS credentials are not hard-coded in the Terraform source code.

Terraform was executed using an **IAM Role attached to the management EC2 instance**.

---

## Terraform Remote State

Terraform state is stored remotely using an **Amazon S3 backend**.

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

---

## Deployment

### Clone the repository

```bash
git clone https://github.com/eetemanojkumar-sys/terraform-project-3-tier-architecture.git

cd terraform-project-3-tier-architecture
```

### Initialize Terraform

```bash
terraform init
```

### Format

```bash
terraform fmt -recursive
```

### Validate

```bash
terraform validate
```

### Preview infrastructure changes

```bash
terraform plan
```

### Deploy

```bash
terraform apply
```

---

## Infrastructure Validation

After deployment, Terraform state can be inspected using:

```bash
terraform state list
```

A second:

```bash
terraform plan
```

was used to verify infrastructure consistency.

The deployed environment returned:

```text
No changes. Your infrastructure matches the configuration.
```

This confirmed that the Terraform state and deployed AWS infrastructure were synchronized.

---

## Destroying the Infrastructure

Because the infrastructure is completely managed through Terraform, it can also be removed using:

```bash
terraform destroy
```

The environment was destroyed after testing and documentation to avoid unnecessary AWS charges.

The Terraform code remains reproducible and can recreate the architecture when required.

---

## Skills Demonstrated

- Terraform Infrastructure as Code
- Terraform Modules
- Terraform Remote State
- AWS VPC Networking
- Multi-AZ Architecture
- Public/Private Subnet Design
- Application Load Balancing
- EC2 Auto Scaling
- Amazon RDS
- Security Groups
- NAT Gateway
- IAM Roles
- Git
- GitHub
- Linux
- Infrastructure lifecycle management

---

## Deployment Evidence

Deployment screenshots will be added to this repository showing:

- Terraform deployment and validation
- VPC and subnet configuration
- Route tables
- Application Load Balancer
- Target Group
- Auto Scaling Group
- EC2 instances
- Amazon RDS
- S3 remote Terraform state

---

## Author

**Manoj Kumar**

Cloud & DevOps

AWS | Terraform | Jenkins | Docker | Kubernetes | Ansible | Linux | Git
