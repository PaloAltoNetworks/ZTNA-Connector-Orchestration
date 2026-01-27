# Azure ZTNA Connector Deployment

A Terraform template for deploying Palo Alto Networks ZTNA (Zero Trust Network Access) Connector on Microsoft Azure.

## Overview

This template deploys a ZTNA Connector instance in Azure using either marketplace or custom images. The connector provides secure remote access capabilities for Prisma Access SASE services. The template supports both 1-NIC and 2-NIC deployment architectures.

## Prerequisites

- Azure subscription with appropriate permissions
- Terraform >= 1.5.0
- Azure CLI installed and configured
- Azure Provider >= 3.0
- ZTNA Connector license key and secret
- Existing resource group
- Existing VNet and subnet(s) or permissions to create new ones

## Architecture Options

### 1-NIC Deployment
- **Instance**: Standard_D4s_v3 (4 vCPUs, 16GB RAM)
- **Network**: Single interface on Internet/Public subnet
- **Use Case**: Simplified deployment with single network interface

### 2-NIC Deployment
- **Instance**: Standard_D4s_v3 (4 vCPUs, 16GB RAM)
- **Network**:
  - NIC1: Internet/Public subnet (DHCP)
  - NIC2: LAN/Private subnet (Static IP)
- **Use Case**: Separation of public and private network traffic

## Quick Start

1. **Clone and configure**:
   ```bash
   cd terraform/azure
   terraform init
   terraform plan
   terraform apply
   ```

2. **Required variables** (create a `terraform.tfvars` file):
   ```hcl
   # Resource Group
   resource_group_name = "my-rg"

   # VM Configuration
   vm_name        = "ztna-connector-vm"
   admin_password = "your-secure-password"

   # Network Configuration
   virtual_network_name     = "my-vnet"
   vnet_new_or_existing     = "existing"  # or "new"
   number_of_nics           = "1"         # or "2"
   subnet1_name             = "Internet"

   # For existing VNet in different resource group:
   # virtual_network_existing_rg_name = "network-rg"

   # For 2-NIC deployment, also add:
   # subnet2_name             = "LAN"
   # dc_lan_port_private_ip   = "10.5.2.44/24"
   # dc_lan_port_gateway      = "10.5.2.1"
   # dc_lan_port_dns          = "8.8.8.8"

   # ZTNA License
   vm_license_key    = "your-license-key"
   vm_license_secret = "your-license-secret"
   ```

## Configuration Variables

### Essential Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | string | - | **Required** - Name of the resource group |
| `vm_name` | string | `"ztna-connector-vm"` | Virtual machine name |
| `admin_password` | string | - | **Required** - Admin password for the VM |
| `vm_license_key` | string | - | **Required** - ZTNA Connector license key |
| `vm_license_secret` | string | - | **Required** - ZTNA Connector license secret |

### Network Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `virtual_network_name` | string | - | **Required** - VNet name |
| `vnet_new_or_existing` | string | `"existing"` | Create new VNet or use existing (`new`/`existing`) |
| `number_of_nics` | string | `"1"` | Number of network interfaces (`1` or `2`) |
| `subnet1_name` | string | `"Internet"` | Internet/Public subnet name |
| `subnet2_name` | string | `"LAN"` | LAN/Private subnet name (for 2-NIC) |
| `virtual_network_address_prefixes` | list(string) | `["10.5.0.0/16"]` | VNet address space (for new VNet) |
| `subnet1_prefix` | string | `"10.5.1.0/24"` | Subnet1 CIDR (for new VNet) |
| `subnet2_prefix` | string | `"10.5.2.0/24"` | Subnet2 CIDR (for new VNet with 2 NICs) |
| `virtual_network_existing_rg_name` | string | `""` | Resource group of existing VNet (if different) |

### 2-NIC Specific Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `dc_lan_port_private_ip` | string | `"10.5.2.44/24"` | Static private IP for LAN interface (IP/CIDR) |
| `dc_lan_port_gateway` | string | `"10.5.2.1"` | Gateway for LAN interface |
| `dc_lan_port_dns` | string | `"8.8.8.8"` | DNS server for LAN interface |

### Compute Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `vm_size` | string | `"Standard_D4s_v3"` | Azure VM size |
| `admin_username` | string | `"adminuser"` | Admin username |
| `availability_zone` | string | `"None"` | Availability zone (1, 2, 3, or None) |
| `availability_set_name` | string | `"None"` | Availability set name (or None) |

### Image Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `use_marketplace_image` | bool | `true` | Use marketplace image vs custom image |
| `marketplace_version` | string | `"latest"` | Marketplace image version |
| `custom_image_id` | string | `""` | Custom image resource ID (if not using marketplace) |

### Other Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `location` | string | `""` | Azure region (defaults to resource group location) |
| `enable_bootstrap` | bool | `true` | Enable bootstrap configuration |
| `tags` | map(string) | `{"paloaltonetworks-ztna" = "ztna-connector-template"}` | Tags for all resources |

## Outputs

| Output | Description |
|--------|-------------|
| `vm_id` | Virtual machine resource ID |
| `vm_name` | Virtual machine name |
| `vm_private_ip` | Primary private IP address |
| `nic1_id` | Network interface 1 resource ID |
| `nic1_private_ip` | NIC1 private IP address |
| `nic2_id` | Network interface 2 resource ID (2-NIC only) |
| `nic2_private_ip` | NIC2 private IP address (2-NIC only) |
| `virtual_network_id` | Virtual network resource ID |
| `subnet1_id` | Subnet 1 resource ID |
| `subnet2_id` | Subnet 2 resource ID (2-NIC only) |

## Example Deployments

### Example 1: Single NIC with Existing VNet

```hcl
# terraform.tfvars
resource_group_name = "ztna-rg"
location           = "eastus"

vm_name        = "ztna-connector-1nic"
admin_password = "SecurePassword123!"

virtual_network_name         = "prod-vnet"
vnet_new_or_existing         = "existing"
virtual_network_existing_rg_name = "network-rg"
subnet1_name                 = "ztna-subnet"
number_of_nics               = "1"

vm_license_key    = "your-license-key"
vm_license_secret = "your-license-secret"
```

### Example 2: Dual NIC with New VNet

```hcl
# terraform.tfvars
resource_group_name = "ztna-rg"
location           = "westus2"

vm_name        = "ztna-connector-2nic"
admin_password = "SecurePassword123!"
availability_zone = "1"

virtual_network_name             = "ztna-vnet"
vnet_new_or_existing             = "new"
virtual_network_address_prefixes = ["10.100.0.0/16"]
subnet1_name                     = "Internet"
subnet1_prefix                   = "10.100.1.0/24"
subnet2_name                     = "LAN"
subnet2_prefix                   = "10.100.2.0/24"
number_of_nics                   = "2"

dc_lan_port_private_ip = "10.100.2.10/24"
dc_lan_port_gateway    = "10.100.2.1"
dc_lan_port_dns        = "10.100.2.2"

vm_license_key    = "your-license-key"
vm_license_secret = "your-license-secret"
```

### Example 3: With Availability Set

```hcl
# terraform.tfvars
resource_group_name = "ztna-rg"

vm_name        = "ztna-connector-avset"
admin_password = "SecurePassword123!"

availability_set_name                        = "ztna-avset"
availability_set_platform_fault_domain_count = 2
availability_set_platform_update_domain_count = 5

virtual_network_name = "prod-vnet"
vnet_new_or_existing = "existing"
subnet1_name         = "ztna-subnet"
number_of_nics       = "1"

vm_license_key    = "your-license-key"
vm_license_secret = "your-license-secret"
```

## Bootstrap Configuration

The connector is automatically configured via custom data (cloud-init) with:
- ION 200v model specification
- License key and secret
- Network interface configuration (DHCP for NIC1, Static for NIC2 if applicable)
- DNS and gateway settings (for 2-NIC deployments)

## Deployment Architecture

```
1-NIC Architecture:
┌─────────────────────────────────────┐
│         Azure VNet                  │
│  ┌──────────────────────────────┐  │
│  │  Internet Subnet             │  │
│  │  ┌────────────────────────┐  │  │
│  │  │  ZTNA Connector VM     │  │  │
│  │  │  - NIC1 (DHCP)         │  │  │
│  │  │  - PublicWAN role      │  │  │
│  │  └────────────────────────┘  │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘

2-NIC Architecture:
┌─────────────────────────────────────────────────┐
│              Azure VNet                         │
│  ┌──────────────────┐  ┌──────────────────┐    │
│  │ Internet Subnet  │  │   LAN Subnet     │    │
│  │  ┌────────────┐  │  │  ┌────────────┐  │    │
│  │  │ NIC1       │  │  │  │ NIC2       │  │    │
│  │  │ (DHCP)     │◄─┼──┼──┤ (Static)   │  │    │
│  │  │ PublicWAN  │  │  │  │ PrivateWAN │  │    │
│  │  └────────────┘  │  │  └────────────┘  │    │
│  │      ▲           │  │        ▲         │    │
│  └──────┼───────────┘  └────────┼─────────┘    │
│         │  ZTNA Connector VM    │              │
│         └───────────────────────┘              │
└─────────────────────────────────────────────────┘
```

## Important Notes

- The VM uses Linux with password authentication enabled
- IP forwarding is enabled on all network interfaces
- Accelerated networking is disabled (as per ARM template specifications)
- For marketplace deployments, appropriate subscription agreements must be accepted
- Availability sets and availability zones are mutually exclusive in Azure

## Comparison with OCI Template

This Azure template mirrors the OCI template structure with the following key mappings:

| OCI Concept | Azure Equivalent |
|-------------|------------------|
| Compartment | Resource Group |
| VCN | Virtual Network (VNet) |
| Subnet OCID | Subnet ID |
| VNIC | Network Interface (NIC) |
| Compute Shape | VM Size |
| Availability Domain | Availability Zone |
| Metadata | Custom Data (cloud-init) |
| Freeform Tags | Tags |
| Marketplace Listing | Marketplace Plan |

## Testing

Run the following to validate the configuration:

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment
terraform plan -var-file="terraform.tfvars"

# Apply configuration
terraform apply -var-file="terraform.tfvars"

# Show outputs
terraform output
```

## Cleanup

To remove all resources:

```bash
terraform destroy -var-file="terraform.tfvars"
```

## Support

This template is based on the Azure ARM templates:
- 1-NIC: `ztna-conn-solution-template-1-arm-v6-template.json`
- 2-NIC: `ztna-conn-solution-template-2-arm-v6-template.json`

For issues or questions, refer to the Palo Alto Networks documentation for ZTNA Connector deployment.
