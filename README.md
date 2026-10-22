# ☁️ AWS Network & Compute Infrastructure with Terraform

**Provisioning secure, cost-conscious AWS infrastructure using Infrastructure as Code.**

![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazonaws)
![Terraform](https://img.shields.io/badge/Terraform-Infrastructure%20as%20Code-7B42BC?logo=terraform)
![Linux](https://img.shields.io/badge/OS-Amazon%20Linux%202023-232F3E?logo=amazonaws)
![Nginx](https://img.shields.io/badge/Web%20Server-Nginx-009639?logo=nginx)
![Status](https://img.shields.io/badge/Infrastructure-Destroyed-success)

> **Project goal:** Build, validate, and deploy a web server on AWS using Terraform, verify connectivity and security, and destroy the infrastructure after testing to reduce ongoing cloud costs.

## 📌 Project Overview

This hands-on cloud engineering project demonstrates how to provision AWS networking and compute resources using Terraform.

The infrastructure was deployed in the **Asia Pacific (Hyderabad) region (`ap-south-2`)**. An Amazon EC2 instance running Amazon Linux 2023 hosted an Nginx web server and served a custom welcome page over HTTP.

The deployment was tested through a browser and SSH session. Nginx was confirmed running, and a local HTTP request returned `200 OK`. After verification, all eight managed AWS resources were destroyed.

## 🏗️ Architecture

**Request flow**

`Internet → Internet Gateway → Public Subnet → Security Group → EC2 → Nginx`

### AWS components

| Component | Purpose |
|---|---|
| Amazon VPC | Isolated network with CIDR `10.10.0.0/16` |
| Public subnet | Subnet with CIDR `10.10.1.0/24` |
| Internet Gateway | Provides internet connectivity for the public subnet |
| Route table | Routes eligible outbound traffic through the Internet Gateway |
| Security group | Controls inbound traffic to the EC2 instance |
| Amazon EC2 | `t3.micro` compute instance |
| Amazon Linux 2023 | Operating system for the web server |
| Nginx | Serves the custom HTML welcome page |
| Terraform | Provisions and manages infrastructure as code |

### 🔐 Security considerations

- SSH access on TCP port 22 was configured to use a specific public IPv4 CIDR (`/32`).
- HTTP access on TCP port 80 was enabled for browser access.
- IMDSv2 was configured as required.
- The root EBS volume was configured as an encrypted 8 GiB `gp3` volume.
- No NAT Gateway or load balancer was deployed.

## 🛠️ Technology Stack

- **Cloud:** AWS
- **Infrastructure as Code:** Terraform
- **Compute:** Amazon EC2
- **Networking:** VPC, subnet, Internet Gateway, route table, security group
- **Operating System:** Amazon Linux 2023
- **Web Server:** Nginx
- **CLI:** AWS CLI, PowerShell, SSH
- **Version Control:** Git and GitHub

## ⚙️ How It Works

### 1. Configure the environment

Configure AWS CLI credentials and select the target region.

```powershell
aws sts get-caller-identity
aws configure get region
```

### 2. Initialize Terraform

From the Terraform configuration directory:

```powershell
terraform init
terraform validate
terraform plan
```

Review the planned resources and security settings before deployment.

### 3. Deploy the infrastructure

```powershell
terraform apply
```

Review the plan and confirm when ready.

### 4. Retrieve the public IP

The `outputs.tf` file exposes the EC2 public IP.

```powershell
terraform output web_public_ip
```

### 5. Verify the web server

Open the resulting public IP in a browser:

```text
http://<EC2_PUBLIC_IP>
```

Verify Nginx over SSH:

```bash
sudo systemctl status nginx
curl -I http://localhost
```

**Expected result:** Nginx is active and the local HTTP request returns `HTTP/1.1 200 OK`.

### 6. Clean up resources

After verification, destroy the infrastructure managed by this Terraform configuration.

```powershell
terraform destroy
terraform state list
```

Review the destroy plan and confirm that only the intended project resources will be removed.

## 📸 Project Evidence

Screenshots are stored in the `screenshots/` directory.

Suggested evidence to include:

- `architecture.png` — actual deployed architecture
- `ec2-instance.png` — EC2 configuration and status
- `terraform-output.png` — Terraform output and state
- `nginx-browser.png` — custom welcome page

*Use your actual screenshot filenames, and update this list to match the files committed to the repository.*

## 📂 Repository Structure

```text
aws-network-compute-terraform/
├── architecture/
│   └── architecture.png
├── screenshots/
├── terraform/
│   ├── version.tf
│   ├── variable.tf
│   ├── locals.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── test/
├── .gitignore
└── README.md
```

> Keep `terraform.tfvars` local if it contains environment-specific configuration. Never commit private SSH keys, Terraform state files, saved plan files, or credentials.

## 💡 Key Learnings

- Provisioning AWS infrastructure using declarative Terraform configuration.
- Designing a public subnet and configuring internet routing.
- Managing EC2 access with security group rules.
- Automating Nginx installation using instance bootstrap configuration.
- Retrieving resource attributes using Terraform outputs.
- Validating deployment through SSH, systemd, and HTTP checks.
- Cleaning up cloud infrastructure after testing to control costs.

## 💰 Cost Awareness

This project intentionally avoids a NAT Gateway and load balancer to reduce unnecessary infrastructure costs.

EC2 runtime, public IPv4 addresses, and EBS storage may incur charges depending on account pricing and credits. The resources used for this deployment have been destroyed after testing.

## 🚀 Future Improvements

- Add a private subnet and NAT-free private workload design.
- Introduce reusable Terraform modules.
- Add automated formatting and validation checks in GitHub Actions.
- Add HTTPS using an appropriate TLS and certificate setup.
- Improve monitoring, logging, and infrastructure documentation.

## 👨‍💻 Project Status

**Deployment verified · Cleanup completed · GitHub publication pending**

This project is part of my hands-on cloud engineering journey, focused on practical AWS networking, compute, Infrastructure as Code, security, and cost awareness.
