# ZTNA Connector Orchestration

This repository contains Terraform configurations for deploying ZTNA (Zero Trust Network Access) Connectors across various cloud providers and architectural patterns. It provides automated infrastructure-as-code (IaC) templates to streamline the deployment of ZTNA connectors.

## Supported Environments

The repository includes connectors for the following cloud providers:
* **AWS** (Amazon Web Services)
* **Azure** (Microsoft Azure)
* **GCP** (Google Cloud Platform)

### Architectures
For each cloud provider, the following deployment architectures are supported where applicable:
* **1 Arm**: Single network interface deployment.
* **1 Arm CSP**: Single network interface with Cloud Service Provider integration.
* **1 Arm CSP Autoscale**: Single network interface with autoscaling capabilities.
* **2 Arm**: Dual network interface deployment (typically for separating management and data traffic).
* **2 Arm CSP**: Dual network interface with Cloud Service Provider integration.

## Prerequisites

Before deploying any connector, ensure you have the following tools installed:

1.  **Terraform**:
    * **MacOS**: Install via Homebrew:
        ```bash
        brew tap hashicorp/tap
        brew install hashicorp/tap/terraform
        ```
    * **Other OS**: Visit the [official Terraform downloads page](https://developer.hashicorp.com/terraform/install).

2.  **Cloud Provider CLI**: Ensure you have the CLI tool installed and authenticated for your target cloud (e.g., `aws`, `az`, or `gcloud`).

## Deployment Instructions

Follow these steps to deploy a ZTNA connector. These instructions assume you are running the commands from the specific directory of the architecture you wish to deploy.

### 1. Update Configuration
Modify the variable files to match your environment. Open `variables.tf` (or `terraform.tfvars`) and update values such as region, VPC IDs, instance types, and authentication tokens.

### 2. Initialize Terraform
Initialize the working directory. This downloads the necessary providers and prepares the environment.
```bash
terraform init

### 3. Plan the Deployment
Generate a deployment plan. This shows exactly what cloud resources will be created.
```bash
terraform plan

### 4. Apply Changes
Attempt to deploy the resources to the cloud.
```bash
terraform apply

## Cleanup
To remove the resources created by this project (destroy the infrastructure), run the following command in the same directory:

```bash
terraform destroy
