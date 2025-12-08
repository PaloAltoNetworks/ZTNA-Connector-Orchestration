# ZTNA Connector Orchestration

This repository contains Terraform configurations for deploying ZTNA (Zero Trust Network Access) Connectors across various cloud providers and architectural patterns. It provides automated infrastructure-as-code (IaC) templates to streamline the deployment of ZTNA connectors.

## Supported Environments

The repository includes connectors for the following cloud providers. Navigate to `terraform_connector/` to see the full list.

### AWS (Amazon Web Services)
* **1 Arm**: Single network interface deployment (`aws_1_arm`).
* **1 Arm CSP**: Single network interface with Cloud Service Provider integration (`aws_1_arm_csp`).
* **1 Arm CSP Autoscale**: Single interface with autoscaling (`aws_1_arm_csp_autoscale`).
* **2 Arm**: Dual network interface deployment (`aws_2_arm`).
* **2 Arm CSP**: Dual network interface with CSP integration (`aws_2_arm_csp`).

### Azure (Microsoft Azure)
* **1 Arm**: Single network interface deployment (`azure_1_arm`).
* **1 Arm CSP**: Single network interface with Cloud Service Provider integration (`azure_1_arm_csp`).
* **1 Arm CSP Autoscale**: Single interface with autoscaling (`azure_1_arm_csp_autoscale`).
* **2 Arm**: Dual network interface deployment (`azure_2_arm`).
* **2 Arm CSP**: Dual network interface with CSP integration (`azure_2_arm_csp`).

### GCP (Google Cloud Platform)
* **1 Arm**: Single network interface deployment.
* **2 Arm**: Dual network interface deployment.

### OCI (Oracle Cloud Infrastructure)
* **1 Arm**: Single network interface deployment.

### vSphere (VMware)
* **1 Arm**: Single network interface deployment.

## Prerequisites

Before deploying any connector, ensure you have the following tools installed:

1.  **Terraform**:
    * **MacOS**: Install via Homebrew:
        ```bash
        brew tap hashicorp/tap
        brew install hashicorp/tap/terraform
        ```
    * **Other OS**: Visit the [official Terraform downloads page](https://developer.hashicorp.com/terraform/install).

2.  **Cloud Provider CLI**: Ensure you have the CLI tool installed and authenticated for your target cloud (e.g., `aws`, `az`, `gcloud`, or `oci`).

## Deployment Instructions

Follow these steps to deploy a ZTNA connector. These instructions assume you are running commands from the specific architecture directory (e.g., `terraform_connector/aws/aws_1_arm`).

### 1. Update Configuration Files
This repository uses YAML files for configuration. You need to ensure the following files are updated with your credentials and environment details:

* **Cloud Provider Data (`tf_data_<cloud>.yaml`)**
    * **Purpose:** Shared settings for the cloud provider (Credentials, Region, VPC IDs).

* **Connector Metadata (`metadata_<cloud>_<arch>.yaml`)**
    * **Purpose:** Deployment-specific settings (License Key, Registration Secret, Hostname).

### 2. Initialize Terraform
Initialize the working directory to download the necessary providers.
```bash
terraform init
```

### 3. Plan the Deployment
Generate a deployment plan. This shows exactly what cloud resources will be created.
```bash
terraform plan
```

### 4. Apply Changes
Attempt to deploy the resources to the cloud.
```bash
terraform apply
```

## Cleanup

To remove the resources created by this project, you can use the standard Terraform command or the provided helper script.

**Option 1: Standard Destruction**
Run this command inside the directory where you deployed the connector:
```bash
terraform destroy
```
**Option 2: Bulk Cleanup Script**
If a cleanup script is available in your directory (e.g., cleanup_scale_conn.sh), you can run it to remove resources automatically:
```bash
./cleanup_scale_conn.sh
```

## Documentation

For more information, please refer to our [public admin guide linked here](https://docs.paloaltonetworks.com/prisma-access/administration/ztna-connector-in-prisma-access).
