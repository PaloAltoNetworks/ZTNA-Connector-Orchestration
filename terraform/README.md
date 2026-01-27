# ZTNA Connector Multi-Cloud Terraform Deployment

This repository contains unified Terraform templates for deploying Palo Alto Networks ZTNA (Zero Trust Network Access) Connector across multiple cloud providers: Oracle Cloud Infrastructure (OCI), Microsoft Azure, Amazon Web Services (AWS), and VMware vSphere.

## Overview

All cloud provider templates follow the same design pattern:
- Support for both **1-NIC** and **2-NIC** deployments via a `number_of_nics` variable
- Consistent variable naming and structure across providers
- Bootstrap/user data configuration for automatic connector setup
- Modular design with separate files for variables, locals, compute, and outputs

## Directory Structure

```
terraform/
├── README.md                    # This file
├── oci/                         # Oracle Cloud Infrastructure
│   ├── compute.tf
│   ├── data_sources.tf
│   ├── locals.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── versions.tf
├── azure/                       # Microsoft Azure
│   ├── compute.tf
│   ├── data_sources.tf
│   ├── locals.tf
│   ├── outputs.tf
│   ├── variables.tf
│   ├── versions.tf
│   ├── templates/
│   │   ├── cloud-init-1-nic.tpl
│   │   └── cloud-init-2-nic.tpl
│   ├── terraform.tfvars.example
│   └── .gitignore
├── aws/                         # Amazon Web Services
│   ├── compute.tf
│   ├── data_sources.tf
│   ├── locals.tf
│   ├── outputs.tf
│   ├── variables.tf
│   ├── versions.tf
│   ├── templates/
│   │   ├── user-data-1-nic.tpl
│   │   └── user-data-2-nic.tpl
│   ├── terraform.tfvars.example
│   └── .gitignore
└── vsphere/                     # VMware vSphere
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── versions.tf
    ├── modules/
    │   ├── 1-nic/               # 1-NIC module
    │   │   ├── main.tf
    │   │   ├── variables.tf
    │   │   ├── data_sources.tf
    │   │   └── outputs.tf
    │   └── 2-nic/               # 2-NIC module
    │       ├── main.tf
    │       ├── variables.tf
    │       ├── data_sources.tf
    │       └── outputs.tf
    ├── terraform.tfvars.example
    └── .gitignore
```

## Quick Start by Provider

### Oracle Cloud Infrastructure (OCI)

```bash
cd oci/
terraform init
terraform plan
terraform apply
```

**Required Variables:**
- `compartment_ocid` - Target compartment
- `internet_subnet_id` - Subnet for NIC1
- `vm_license_key` - ZTNA license key
- `vm_license_secret` - ZTNA license secret

See [oci/README.md](oci/README.md) for details.

### Microsoft Azure

```bash
cd azure/
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

**Required Variables:**
- `resource_group_name` - Resource group
- `virtual_network_name` - VNet name
- `admin_password` - VM admin password
- `vm_license_key` - ZTNA license key
- `vm_license_secret` - ZTNA license secret

See [azure/README.md](azure/README.md) for details.

### Amazon Web Services (AWS)

```bash
cd aws/
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

**Required Variables:**
- `vpc_id` - VPC ID
- `public_subnet_id` - Subnet for NIC1
- `vm_license_key` - ZTNA license key
- `vm_license_secret` - ZTNA license secret

See [aws/README.md](aws/README.md) for details.

### VMware vSphere

```bash
cd vsphere/
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
# Set vSphere credentials via environment variables
export VSPHERE_SERVER="vcenter.example.com"
export VSPHERE_USER="administrator@vsphere.local"
export VSPHERE_PASSWORD="your-password"
terraform init
terraform plan
terraform apply
```

**Required Variables:**
- `datacenter` - vSphere datacenter name
- `datastore` - Datastore for VM
- `port1_network` - Port group for NIC1
- `vm_license_key` - ZTNA license key
- `vm_license_secret` - ZTNA license secret

**Note:** vSphere requires OVA files (`200v-1-nic.ova`, `200v-2-nic.ova`) to be present.

See [vsphere/README.md](vsphere/README.md) for details.

## Architecture Comparison

### 1-NIC Deployment

All providers support a simplified single-interface deployment:

| Provider | Instance Type | Network Role | IP Assignment |
|----------|---------------|--------------|---------------|
| **OCI** | VM.Standard.E5.Flex (2 OCPU, 16GB) | PublicWAN | DHCP |
| **Azure** | Standard_D4s_v3 (4 vCPU, 16GB) | PublicWAN | DHCP |
| **AWS** | m5.xlarge (4 vCPU, 16GB) | PublicWAN | DHCP/Static |
| **vSphere** | 4 vCPU, 8GB RAM | PublicWAN | DHCP/Static |

### 2-NIC Deployment

Dual-interface deployment for traffic separation:

| Provider | NIC1 Role | NIC1 IP | NIC2 Role | NIC2 IP |
|----------|-----------|---------|-----------|---------|
| **OCI** | PublicWAN | DHCP | LAN | Static |
| **Azure** | PublicWAN | DHCP | PrivateWAN | Static |
| **AWS** | PublicWAN | DHCP | PrivateWAN | DHCP |
| **vSphere** | PublicWAN | DHCP/Static | LAN | DHCP/Static |

## Variable Mapping Across Providers

### Core Variables

| Purpose | OCI | Azure | AWS |
|---------|-----|-------|-----|
| **Number of NICs** | `number_of_nics` | `number_of_nics` | `number_of_nics` |
| **Instance Name** | `vm_display_name` | `vm_name` | `instance_name` |
| **License Key** | `vm_license_key` | `vm_license_key` | `vm_license_key` |
| **License Secret** | `vm_license_secret` | `vm_license_secret` | `vm_license_secret` |

### Network Variables

| Purpose | OCI | Azure | AWS |
|---------|-----|-------|-----|
| **Virtual Network** | Compartment + VCN | `virtual_network_name` | `vpc_id` |
| **Public Subnet** | `internet_subnet_id` | `subnet1_name` | `public_subnet_id` |
| **Private Subnet** | `data_center_subnet_id` | `subnet2_name` | `private_subnet_id` |

### Compute Variables

| Purpose | OCI | Azure | AWS |
|---------|-----|-------|-----|
| **Instance Size** | `vm_compute_shape` | `vm_size` | `instance_type` |
| **Availability** | `availability_domain_name` | `availability_zone` | `availability_zone` |
| **Image** | `custom_image_id` / `mp_listing_resource_id` | `custom_image_id` / marketplace | `custom_ami_id` / `regional_ami_map` |

## Bootstrap Configuration

All templates use cloud-init/user data for automatic configuration:

### 1-NIC Bootstrap Format
```yaml
General:
  model: ion 200v

License:
  key: <license_key>
  secret: <license_secret>

1:
  role: PublicWAN
  type: DHCP
```

### 2-NIC Bootstrap Format
```yaml
General:
  model: ion 200v

License:
  key: <license_key>
  secret: <license_secret>

1:
  role: PublicWAN
  type: DHCP

2:
  role: LAN/PrivateWAN
  type: DHCP/STATIC
  # Additional config for Azure 2-NIC (static IP, gateway, DNS)
```

## Common Outputs

All templates provide similar outputs:

| Output | Description | OCI | Azure | AWS |
|--------|-------------|-----|-------|-----|
| **Instance ID** | Compute instance identifier | ✓ | ✓ | ✓ |
| **Private IP** | Primary NIC private IP | ✓ | ✓ | ✓ |
| **NIC IDs** | Network interface IDs | ✓ | ✓ | ✓ |
| **Subnet IDs** | Subnet identifiers | ✓ | ✓ | ✓ |

## Source Templates

The Terraform templates were converted from the following source templates:

### OCI
- **Source**: Native OCI Terraform
- **Location**: `oci/*.tf`
- **Original**: Marketplace listing template

### Azure
- **Source**: ARM Templates (JSON)
- **Templates**:
  - `azure/ztna-conn-solution-template-1-arm-v6-template.json` (1-NIC)
  - `azure/ztna-conn-solution-template-2-arm-v6-template.json` (2-NIC)
- **Converted**: Native Terraform for Azure

### AWS
- **Source**: CloudFormation Templates (YAML)
- **Templates**:
  - `aws/AWS-PA-ZTNA-Connector-1ARM.yaml` (1-NIC)
  - `aws/AWS-PA-ZTNA-Connector-2ARM.yaml` (2-NIC)
- **Converted**: Native Terraform for AWS

### vSphere
- **Source**: OVF Templates (XML)
- **Templates**:
  - `vsphere/200v-1-nic.ovf` (1-NIC)
  - `vsphere/200v-2-nic.ovf` (2-NIC)
- **Converted**: Modular Terraform with OVA deployment (separate modules for 1-NIC and 2-NIC)

## Key Features

### Unified Design
- ✅ Single `number_of_nics` variable controls 1-NIC vs 2-NIC deployment
- ✅ Consistent file structure across all providers
- ✅ Similar variable naming conventions
- ✅ Standardized bootstrap configuration

### Provider-Specific Optimizations
- **OCI**: Marketplace subscription support, availability domain selection
- **Azure**: Availability zones, availability sets, marketplace plan support
- **AWS**: Regional AMI mapping, source/destination check configuration
- **vSphere**: OVA deployment, vApp properties configuration, modular architecture

### Security
- All templates create minimal-permission security groups/rules
- License secrets marked as sensitive
- `.gitignore` files prevent credential leakage (Azure, AWS)
- No hardcoded credentials

### Flexibility
- Support for both marketplace and custom images
- Optional static IP assignment
- Configurable storage/volume sizes
- Tag/label support for resource organization

## Best Practices

1. **Always use a `.tfvars` file** for sensitive values (never commit to git)
2. **Test in a non-production environment** before deploying to production
3. **Review the plan output** before applying (`terraform plan`)
4. **Use remote state** for team collaboration (S3, Azure Blob, OCI Object Storage)
5. **Tag resources consistently** for cost tracking and organization
6. **Document custom configurations** in your local README

## Support and Documentation

- **OCI Template**: See [oci/README.md](oci/README.md)
- **Azure Template**: See [azure/README.md](azure/README.md)
- **AWS Template**: See [aws/README.md](aws/README.md)
- **vSphere Template**: See [vsphere/README.md](vsphere/README.md)
- **Palo Alto Networks ZTNA**: [Official Documentation](https://docs.paloaltonetworks.com/)

## Version Requirements

| Tool | Minimum Version |
|------|----------------|
| Terraform | >= 1.5.0 |
| OCI Provider | >= 6.30 |
| Azure Provider (azurerm) | >= 3.0 |
| AWS Provider | >= 5.0 |
| vSphere Provider | >= 2.0 |

## License

Refer to individual template directories for licensing information.

## Contributing

When adding new features or cloud providers:
1. Maintain consistent file structure
2. Use the same variable naming patterns
3. Document all variables in README
4. Provide example `.tfvars` files
5. Include bootstrap/user data templates
