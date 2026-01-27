# vSphere ZTNA Connector Deployment

A modular Terraform template for deploying Palo Alto Networks ZTNA (Zero Trust Network Access) Connector on VMware vSphere from OVA files.

## Overview

This template provides a unified interface for deploying ZTNA Connector on vSphere with support for both 1-NIC and 2-NIC architectures. The deployment uses separate OVA files for each configuration and is controlled by the `number_of_nics` variable, similar to the OCI/Azure/AWS templates.

## Architecture

The vSphere deployment is structured as a **modular Terraform configuration**:

```
vsphere/
├── main.tf              # Root module - wraps 1-NIC and 2-NIC modules
├── variables.tf         # Unified variables
├── outputs.tf           # Unified outputs
├── versions.tf          # Provider requirements
├── modules/
│   ├── 1-nic/           # Module for 1-NIC deployment
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── data_sources.tf
│   │   └── outputs.tf
│   └── 2-nic/           # Module for 2-NIC deployment
│       ├── main.tf
│       ├── variables.tf
│       ├── data_sources.tf
│       └── outputs.tf
├── 200v-1-nic.ova       # 1-NIC OVA file (not in repo)
└── 200v-2-nic.ova       # 2-NIC OVA file (not in repo)
```

## Prerequisites

- VMware vSphere environment (vCenter or ESXi)
- Terraform >= 1.5.0
- vSphere Provider >= 2.0
- ZTNA Connector license key and secret
- OVA files:
  - `200v-1-nic.ova` (for 1-NIC deployments)
  - `200v-2-nic.ova` (for 2-NIC deployments)
- vSphere credentials with permissions to:
  - Deploy OVF templates
  - Create virtual machines
  - Configure network interfaces

## OVA File Specifications

### Hardware Requirements (from OVF)

| Component | 1-NIC | 2-NIC |
|-----------|-------|-------|
| **vCPUs** | 4 | 4 |
| **Cores per Socket** | 4 | 4 |
| **Memory** | 8192 MB | 8192 MB |
| **Disk** | 40 GB | 40 GB |
| **Guest OS** | Ubuntu 64-bit | Ubuntu 64-bit |
| **Firmware** | BIOS | BIOS |
| **Network Adapter** | VmxNet3 | VmxNet3 |

### Network Configuration

**1-NIC Deployment:**
- **Port1**: PublicWAN role (DHCP or Static)

**2-NIC Deployment:**
- **Port1**: PublicWAN role (DHCP or Static)
- **Port2**: LAN role (DHCP or Static)

## Quick Start

1. **Obtain OVA files** and place them in the `vsphere/` directory:
   ```bash
   # OVA files should be present:
   ls -la *.ova
   # 200v-1-nic.ova
   # 200v-2-nic.ova
   ```

2. **Configure credentials**:
   ```bash
   export VSPHERE_SERVER="vcenter.example.com"
   export VSPHERE_USER="administrator@vsphere.local"
   export VSPHERE_PASSWORD="your-password"
   ```

3. **Create terraform.tfvars**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

4. **Deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration Variables

### Essential Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `number_of_nics` | string | `"1"` | **Control variable** - "1" or "2" |
| `datacenter` | string | - | **Required** - vSphere datacenter name |
| `datastore` | string | - | **Required** - Datastore for VM |
| `port1_network` | string | - | **Required** - Port group for Port1 |
| `license_key` | string | - | **Required** - ZTNA license key |
| `license_secret` | string | - | **Required** - ZTNA license secret |

### vSphere Infrastructure

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `cluster` | string | `""` | Cluster name (optional) |
| `resource_pool` | string | `""` | Resource pool name (optional) |
| `folder` | string | `""` | VM folder path (optional) |

### OVA File Paths

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `ovf_1nic_local_path` | string | `"./200v-1-nic.ova"` | Path to 1-NIC OVA |
| `ovf_2nic_local_path` | string | `"./200v-2-nic.ova"` | Path to 2-NIC OVA |
| `ovf_1nic_remote_url` | string | `""` | Remote URL for 1-NIC OVA |
| `ovf_2nic_remote_url` | string | `""` | Remote URL for 2-NIC OVA |
| `allow_unverified_ssl` | bool | `false` | Allow unverified SSL for OVF |

### VM Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `vm_name` | string | `"ztna-connector-vm"` | Virtual machine name |
| `num_cpus` | number | `4` | Number of vCPUs |
| `num_cores_per_socket` | number | `4` | Cores per socket |
| `memory_mb` | number | `8192` | Memory in MB |
| `disk_size_gb` | number | `40` | Disk size in GB |
| `disk_thin_provisioned` | bool | `true` | Use thin provisioning |
| `guest_id` | string | `"ubuntu64Guest"` | Guest OS type |
| `firmware` | string | `"bios"` | Firmware (bios/efi) |

### Network Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `port2_network` | string | `""` | Port group for Port2 (2-NIC only) |
| `port1_adapter_type` | string | `"vmxnet3"` | Adapter type for Port1 |
| `port2_adapter_type` | string | `"vmxnet3"` | Adapter type for Port2 |

### Port 1 Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `port1_type` | string | `"DHCP"` | Configuration type (DHCP/Static) |
| `port1_ip` | string | `"0.0.0.0"` | Static IP (0.0.0.0 = DHCP) |
| `port1_subnet` | number | `0` | Subnet mask (CIDR, 0-32) |
| `port1_gateway` | string | `"0.0.0.0"` | Gateway IP |
| `port1_dns1` | string | `"0.0.0.0"` | Primary DNS |
| `port1_dns2` | string | `"0.0.0.0"` | Secondary DNS |

### Port 2 Configuration (2-NIC only)

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `port2_type` | string | `"DHCP"` | Configuration type (DHCP/Static) |
| `port2_ip` | string | `"0.0.0.0"` | Static IP |
| `port2_subnet` | number | `0` | Subnet mask (CIDR) |
| `port2_gateway` | string | `"0.0.0.0"` | Gateway IP |
| `port2_dns1` | string | `"0.0.0.0"` | Primary DNS |
| `port2_dns2` | string | `"0.0.0.0"` | Secondary DNS |

### Advanced Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `host1_name` | string | `"controller.cgnx.net"` | Static host entry 1 name |
| `host1_ip` | string | `"0.0.0.0"` | Static host entry 1 IP |
| `host2_name` | string | `"vmfg.cgnx.net"` | Static host entry 2 name |
| `host2_ip` | string | `"0.0.0.0"` | Static host entry 2 IP |
| `host3_name` | string | `"locator.cgnx.net"` | Static host entry 3 name |
| `host3_ip` | string | `"0.0.0.0"` | Static host entry 3 IP |

### Tags and Metadata

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `tags` | list(string) | `["ztna-connector"]` | vSphere tags |
| `custom_attributes` | map(string) | `{}` | Custom attributes |
| `annotation` | string | `"ZTNA Connector ION 200v"` | VM notes |

## Outputs

| Output | Description |
|--------|-------------|
| `vm_id` | Virtual machine ID |
| `vm_name` | Virtual machine name |
| `vm_uuid` | Virtual machine UUID |
| `vm_moid` | Managed object ID |
| `default_ip_address` | Default IP address |
| `guest_ip_addresses` | All guest IP addresses |
| `port1_network_id` | Port1 network ID |
| `port2_network_id` | Port2 network ID (2-NIC only) |
| `datastore_id` | Datastore ID |
| `resource_pool_id` | Resource pool ID |
| `number_of_nics` | Number of NICs deployed |

## Example Deployments

### Example 1: 1-NIC with DHCP

```hcl
# terraform.tfvars
number_of_nics = "1"

datacenter = "Production-DC"
cluster    = "Compute-Cluster"
datastore  = "datastore1"
folder     = "/VMs/ZTNA"

vm_name = "ztna-connector-1nic"

port1_network = "VM Network"
port1_type    = "DHCP"

license_key    = "your-license-key"
license_secret = "your-license-secret"

tags = ["ztna", "production", "1-nic"]
```

### Example 2: 1-NIC with Static IP

```hcl
# terraform.tfvars
number_of_nics = "1"

datacenter = "Production-DC"
datastore  = "datastore1"

vm_name = "ztna-connector-static"

port1_network  = "DMZ-Network"
port1_type     = "Static"
port1_ip       = "192.168.100.50"
port1_subnet   = 24
port1_gateway  = "192.168.100.1"
port1_dns1     = "8.8.8.8"
port1_dns2     = "8.8.4.4"

license_key    = "your-license-key"
license_secret = "your-license-secret"
```

### Example 3: 2-NIC with Mixed Configuration

```hcl
# terraform.tfvars
number_of_nics = "2"

datacenter = "Production-DC"
cluster    = "Compute-Cluster"
datastore  = "datastore1"

vm_name = "ztna-connector-2nic"

# Port1: PublicWAN (DHCP)
port1_network = "Internet"
port1_type    = "DHCP"

# Port2: LAN (Static IP)
port2_network  = "Internal-LAN"
port2_type     = "Static"
port2_ip       = "10.0.1.100"
port2_subnet   = 24
port2_gateway  = "10.0.1.1"
port2_dns1     = "10.0.1.2"

license_key    = "your-license-key"
license_secret = "your-license-secret"

tags = ["ztna", "production", "2-nic"]
```

### Example 4: Using Remote OVA URL

```hcl
# terraform.tfvars
number_of_nics = "1"

datacenter = "Production-DC"
datastore  = "datastore1"

# Use remote OVA instead of local file
ovf_1nic_remote_url  = "https://repo.example.com/ztna/200v-1-nic.ova"
allow_unverified_ssl = false

vm_name       = "ztna-connector-remote"
port1_network = "VM Network"
port1_type    = "DHCP"

license_key    = "your-license-key"
license_secret = "your-license-secret"
```

## OVF Properties

The OVA files include vApp properties that are automatically configured:

### Licensing Properties
- `key` - License key
- `secret` - License secret (sensitive)

### Model Property
- `type` - Always set to "ion 200v"

### Port Configuration Properties

For each port (port1, port2):
- `port{N}role` - Port role (PublicWAN or LAN)
- `port{N}type` - DHCP or Static
- `port{N}ip` - IP address (0.0.0.0 for DHCP)
- `port{N}subnet` - Subnet mask in CIDR notation
- `port{N}gateway` - Gateway IP
- `port{N}dns1` - Primary DNS
- `port{N}dns2` - Secondary DNS
- `port{N}name` - Port number identifier

### Advanced Properties
- `host1name`, `host1ip` - Static host entry 1
- `host2name`, `host2ip` - Static host entry 2
- `host3name`, `host3ip` - Static host entry 3

## Module Structure

The deployment uses a wrapper pattern:

```
Root Module (main.tf)
├── Conditionally deploys: modules/1-nic (if number_of_nics == "1")
└── Conditionally deploys: modules/2-nic (if number_of_nics == "2")
```

This design provides:
- **Unified interface**: Same variables as OCI/Azure/AWS templates
- **Separate OVA files**: Each module uses its dedicated OVA
- **Clean separation**: 1-NIC and 2-NIC logic isolated in modules
- **Single `number_of_nics` control**: Easy switching between architectures

## Comparison with Other Cloud Providers

| Feature | OCI | Azure | AWS | vSphere |
|---------|-----|-------|-----|---------|
| **Control Variable** | `number_of_nics` | `number_of_nics` | `number_of_nics` | `number_of_nics` |
| **Deployment Method** | Instance | VM | EC2 | OVA/OVF |
| **Image Source** | Custom/Marketplace | Custom/Marketplace | AMI | Local/Remote OVA |
| **Module Structure** | Single | Single | Single | Wrapper + Submodules |
| **Bootstrap** | Metadata | Custom Data | User Data | vApp Properties |

## Important Notes

### vApp Properties vs. Cloud-Init
- vSphere uses **vApp properties** (OVF environment) for configuration
- Cloud providers (OCI/Azure/AWS) use cloud-init/user data
- Both methods achieve the same result: automatic connector configuration

### OVA Files
- OVA files are **not included** in the repository (large binary files)
- Must be obtained separately and placed in the `vsphere/` directory
- Can also be hosted remotely and referenced via URL

### Network Adapter Types
- Default: **vmxnet3** (VMware paravirtualized adapter)
- Alternatives: e1000, e1000e (for compatibility)
- VmxNet3 recommended for best performance

### Disk Provisioning
- **Thin provisioning** (default): Disk grows as needed
- **Thick provisioning**: Full disk allocated upfront
- Thin provisioning saves storage but may impact performance

## Troubleshooting

### OVA Not Found
```
Error: error deploying OVF: file not found
```
**Solution**: Ensure OVA files are present in the specified path.

### Network Not Found
```
Error: network 'VM Network' not found
```
**Solution**: Verify the port group name matches exactly (case-sensitive).

### Permission Denied
```
Error: user does not have permission to deploy OVF
```
**Solution**: Ensure vSphere user has required permissions:
- Deploy OVF template
- Create virtual machine
- Configure network

### vApp Properties Not Applied
```
Warning: vApp properties ignored
```
**Solution**: Ensure VMware Tools is installed in the OVA and `ovf:transport="com.vmware.guestInfo"` is set.

## Best Practices

1. **Use local OVA files** for faster deployment
2. **Enable thin provisioning** to optimize storage
3. **Use vmxnet3 adapters** for best performance
4. **Set static IPs** for production deployments
5. **Tag VMs** for easy identification and management
6. **Document custom attributes** for organizational tracking
7. **Test in non-production** before deploying to production

## Support

This template is based on the OVF files:
- [200v-1-nic.ovf](200v-1-nic.ovf)
- [200v-2-nic.ovf](200v-2-nic.ovf)

For issues or questions, refer to:
- Palo Alto Networks ZTNA Connector documentation
- VMware vSphere OVF Tool documentation
- Terraform vSphere Provider documentation
