# 🌐 Multi-Cloud Kubernetes & Server Deployment

Deploy **Kubernetes clusters** and **server instances** across **AWS, Azure, GCP, and Hetzner** using a single, interactive Makefile and modular Terraform infrastructure.

<p align="center">
  <img alt="status" src="https://img.shields.io/badge/IaC-Terraform-5C4EE5?style=for-the-badge">
  <img alt="k8s" src="https://img.shields.io/badge/Kubernetes-Ready-326CE5?style=for-the-badge">
  <img alt="multi-cloud" src="https://img.shields.io/badge/Multi--Cloud-AWS%20|%20Azure%20|%20GCP%20|%20Hetzner-111?style=for-the-badge">
</p>

---

## ✨ Features

- **🎯 One interface for four clouds** — Interactive prompts to select provider & deployment type
- **🔄 Dual deployment modes** — **Kubernetes** (EKS/AKS/GKE) or **Server** (VMs/Compute instances)
- **🌍 Environment-driven** — Switch configurations via `ENV=<environment>` parameter
- **📦 Modular architecture** — Clean, isolated Terraform modules per cloud provider and deployment type
- **⚡ Quick deployment** — Single command execution with guided setup

---

## 📂 Repository Structure

```
📦 multi-cloud-deployment
├── 📂 environments/
│   ├── 📄 terraform.tfvars
│
├── 📂 modules/
│   ├── ☁️ aws/
│   │   ├── 📂 k8s/
│   │   └── 📂 server/
│   │
│   ├── ☁️ azure/
│   │   ├── 📂 k8s/  
│   │   └── 📂 server/ 
│   │
│   ├── ☁️ gcp/
│   │   ├── 📂 k8s/    
│   │   └── 📂 server/    
│   │
│   ├── 🇩🇪 hetzner/
│   │   └── 📂 server/  
│   │
│   └── 🔧 scripts/       
│
├── 📄 Makefile           
└── 📄 README.md            
```

---

## 🛠 Prerequisites

Before getting started, ensure you have:

- **Terraform** >= 1.0 installed
- **Make** utility available
- Cloud provider credentials configured:
  - **AWS**: `aws configure` or environment variables
  - **Azure**: `az login` or service principal
  - **GCP**: Service account key or `gcloud auth`
  - **Hetzner**: API token in environment variables



## 🚀 Setup Steps

### 📝 Plan (Preview Changes)

Update **terraform.tfvars** file as per credentials and server as a needed configuration 

### 📝 Plan (Preview Changes)

Preview what infrastructure will be created without making any changes:

```bash
make plan
```

**Interactive Flow:**
1. **Select Cloud Provider:**
   ```
   Select Cloud Provider:
   1) AWS
   2) Azure  
   3) GCP
   4) Hetzner
   ```

2. **Select Deployment Type:**
   ```
   Select Deployment Type:
   1) Kubernetes
   2) Server
   ```
   > **Note:** Hetzner only supports Server-based deployment

3. **Terraform Plan Execution:**
   - Shows detailed preview of resources to be created/modified/destroyed
   - No actual infrastructure changes are made

### 🚀 Apply (Deploy Infrastructure)

Deploy your infrastructure to the selected cloud provider:

```bash
make apply
```

**Interactive Flow:**
1. **Select Cloud Provider** (same as plan)
2. **Select Deployment Type** (same as plan)
3. **Terraform Apply:**
   - Creates/updates infrastructure based on your selections
   - Displays real-time provisioning progress
   - Outputs connection details upon completion

### 🗑 Destroy (Clean Up)

Remove all deployed infrastructure:

```bash
make destroy
```

Follows the same interactive flow and safely removes all created resources.

---

## 📋 Available Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `make plan` | Preview infrastructure changes | `make plan` |
| `make apply` | Deploy infrastructure | `make apply` |
| `make destroy` | Remove infrastructure | `make destroy` |
| `make validate` | Validate Terraform code | `make validate` |
| `make format` | Format Terraform files | `make format` |

---

## ☁️ Cloud Provider Support

| Provider | Kubernetes | Server | Status |
|----------|------------|--------|---------|
| **AWS** | ✅ EKS | ✅ EC2 | Full Support |
| **Azure** | ✅ AKS | ✅ VM | Full Support |
| **GCP** | ✅ GKE | ✅ Compute Engine | Full Support |
| **Hetzner** | ❌ | ✅ Cloud Server | Server Only |

---



<p align="center">
  <strong>🚀 Happy Deploying! 🚀</strong>
</p>