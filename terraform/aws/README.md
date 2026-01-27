# AWS ZTNA Connector Deployment

A Terraform template for deploying Palo Alto Networks ZTNA (Zero Trust Network Access) Connector on Amazon Web Services (AWS).

## Overview

This template deploys a ZTNA Connector EC2 instance in AWS using regional AMI mappings or custom AMIs. The connector provides secure remote access capabilities for Prisma Access SASE services. The template supports both 1-NIC and 2-NIC deployment architectures.

## Prerequisites

- AWS account with appropriate permissions
- Terraform >= 1.5.0
- AWS CLI installed and configured
- AWS Provider >= 5.0
- ZTNA Connector license key and secret
- Existing VPC and subnet(s)
- (Optional) EC2 Key Pair for SSH access

## Architecture Options

### 1-NIC Deployment
- **Instance Type**: m5.xlarge (4 vCPUs, 16GB RAM)
- **Network**: Single interface on a subnet (can be public or private)
- **Source/Dest Check**: Disabled (allows routing)
- **Use Case**: Simplified deployment with single network interface

### 2-NIC Deployment
- **Instance Type**: m5.xlarge (4 vCPUs, 16GB RAM)
- **Network**:
  - NIC1: Public/Internet subnet (DHCP, PublicWAN role)
  - NIC2: Private/LAN subnet (DHCP, PrivateWAN role)
- **Source/Dest Check**:
  - NIC1: Enabled
  - NIC2: Disabled
- **Use Case**: Separation of public and private network traffic

## Quick Start

1. **Clone and configure**:
   ```bash
   cd terraform/aws
   terraform init
   terraform plan
   terraform apply
   ```

2. **Required variables** (create a `terraform.tfvars` file):
   ```hcl
   # VPC Configuration
   vpc_id            = "vpc-xxxxxxxxxxxxxxxxx"
   public_subnet_id  = "subnet-xxxxxxxxxxxxxxxxx"

   # For 2-NIC deployment:
   # number_of_nics    = "2"
   # private_subnet_id = "subnet-yyyyyyyyyyyyyyyyy"

   # ZTNA License
   vm_license_key    = "your-license-key"
   vm_license_secret = "your-license-secret"
   ```

## Configuration Variables

### Essential Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `vpc_id` | string | - | **Required** - VPC ID for deployment |
| `public_subnet_id` | string | - | **Required** - Subnet ID for NIC1 |
| `vm_license_key` | string | - | **Required** - ZTNA Connector license key |
| `vm_license_secret` | string | - | **Required** - ZTNA Connector license secret |

### Network Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `number_of_nics` | string | `"1"` | Number of network interfaces (`1` or `2`) |
| `private_subnet_id` | string | `""` | Subnet ID for NIC2 (2-NIC only) |
| `public_nic_private_ip` | string | `"0.0.0.0"` | Static IP for NIC1 (0.0.0.0 = DHCP) |
| `private_nic_private_ip` | string | `"0.0.0.0"` | Static IP for NIC2 (0.0.0.0 = DHCP) |

### Compute Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `instance_name` | string | `"ztna-connector-vm"` | EC2 instance name |
| `instance_type` | string | `"m5.xlarge"` | EC2 instance type (ION 200v) |
| `availability_zone` | string | `""` | Availability zone (e.g., us-east-1a) |
| `key_name` | string | `""` | EC2 key pair name for SSH access |

### AMI Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `use_custom_ami` | bool | `false` | Use custom AMI vs regional mapping |
| `custom_ami_id` | string | `""` | Custom AMI ID (if use_custom_ami is true) |
| `regional_ami_map` | map(string) | See variables.tf | Map of regions to AMI IDs |

### Security Group Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `create_security_group` | bool | `true` | Create new security group |
| `security_group_id` | string | `""` | Existing SG ID (if not creating) |
| `security_group_name` | string | `"ztna-connector-sg"` | Name for new security group |
| `allowed_ingress_cidrs` | list(string) | `[]` | CIDR blocks for ingress (empty = egress only) |

### Storage Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `root_volume_size` | number | `30` | Root volume size in GB |
| `root_volume_type` | string | `"gp3"` | EBS volume type (gp2, gp3, io1, io2) |
| `root_volume_delete_on_termination` | bool | `true` | Delete volume on termination |

### Other Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `region` | string | `""` | AWS region (defaults to current) |
| `enable_bootstrap` | bool | `true` | Enable bootstrap via user data |
| `tags` | map(string) | See variables.tf | Tags for all resources |

## Outputs

| Output | Description |
|--------|-------------|
| `instance_id` | EC2 instance ID |
| `instance_arn` | EC2 instance ARN |
| `instance_state` | Instance state |
| `public_nic_id` | Network interface 1 ID |
| `public_nic_private_ip` | NIC1 private IP address |
| `private_nic_id` | Network interface 2 ID (2-NIC only) |
| `private_nic_private_ip` | NIC2 private IP address (2-NIC only) |
| `security_group_id` | Security group ID |
| `ami_id` | AMI ID used |
| `region` | AWS region |

## Example Deployments

### Example 1: Single NIC with Default AMI

```hcl
# terraform.tfvars
region = "us-east-1"

instance_name = "ztna-connector-1nic"
instance_type = "m5.xlarge"
key_name      = "my-ec2-keypair"

vpc_id           = "vpc-0123456789abcdef0"
public_subnet_id = "subnet-0123456789abcdef0"
number_of_nics   = "1"

# Use DHCP for IP assignment
public_nic_private_ip = "0.0.0.0"

vm_license_key    = "your-license-key"
vm_license_secret = "your-license-secret"

tags = {
  Environment = "Production"
  Team        = "Security"
}
```

### Example 2: Dual NIC with Static IPs

```hcl
# terraform.tfvars
region            = "us-west-2"
availability_zone = "us-west-2a"

instance_name = "ztna-connector-2nic"

vpc_id            = "vpc-0123456789abcdef0"
public_subnet_id  = "subnet-0123456789abcdef0"
private_subnet_id = "subnet-0fedcba9876543210"
number_of_nics    = "2"

# Static IP assignments
public_nic_private_ip  = "10.0.1.50"
private_nic_private_ip = "10.0.2.50"

vm_license_key    = "your-license-key"
vm_license_secret = "your-license-secret"
```

### Example 3: Custom AMI with Existing Security Group

```hcl
# terraform.tfvars
region = "eu-west-1"

instance_name = "ztna-connector-custom"

# Use custom AMI
use_custom_ami = true
custom_ami_id  = "ami-0123456789abcdef0"

# Use existing security group
create_security_group = false
security_group_id     = "sg-0123456789abcdef0"

vpc_id           = "vpc-0123456789abcdef0"
public_subnet_id = "subnet-0123456789abcdef0"
number_of_nics   = "1"

vm_license_key    = "your-license-key"
vm_license_secret = "your-license-secret"
```

### Example 4: With Ingress Rules

```hcl
# terraform.tfvars
vpc_id           = "vpc-0123456789abcdef0"
public_subnet_id = "subnet-0123456789abcdef0"
number_of_nics   = "1"

# Create security group with ingress rules
create_security_group = true
security_group_name   = "ztna-connector-sg-prod"
allowed_ingress_cidrs = [
  "10.0.0.0/8",   # Internal networks
  "172.16.0.0/12" # Additional internal
]

vm_license_key    = "your-license-key"
vm_license_secret = "your-license-secret"
```

## Bootstrap Configuration

The connector is automatically configured via EC2 user data with:
- ION 200v model specification
- License key and secret
- Network interface configuration (DHCP for both NICs)
- Role assignments (PublicWAN for NIC1, PrivateWAN for NIC2)

## Regional AMI Mapping

The template includes AMI mappings for the following regions:
- `us-east-1` (N. Virginia) - ami-0ec34647f50fc20e8
- `us-east-2` (Ohio)
- `us-west-1` (N. California)
- `us-west-2` (Oregon)
- `ca-central-1` (Canada)
- `sa-east-1` (São Paulo)
- `eu-central-1` (Frankfurt)
- `eu-west-1` (Ireland)
- `eu-west-2` (London)
- `ap-south-1` (Mumbai)
- `ap-northeast-1` (Tokyo)
- `ap-northeast-2` (Seoul)
- `ap-southeast-1` (Singapore)
- `ap-southeast-2` (Sydney)

**Note**: Most AMI IDs are placeholders (`ami-xxxxxxxxxxxxxxxxx`). Update [`variables.tf`](variables.tf) with actual AMI IDs for your regions.

## Deployment Architecture

```
1-NIC Architecture:
┌─────────────────────────────────────┐
│         AWS VPC                     │
│  ┌──────────────────────────────┐  │
│  │  Subnet                      │  │
│  │  ┌────────────────────────┐  │  │
│  │  │  ZTNA Connector EC2    │  │  │
│  │  │  - NIC1 (DHCP/Static)  │  │  │
│  │  │  - PublicWAN role      │  │  │
│  │  │  - Source/Dest: OFF    │  │  │
│  │  └────────────────────────┘  │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘

2-NIC Architecture:
┌─────────────────────────────────────────────────┐
│              AWS VPC                            │
│  ┌──────────────────┐  ┌──────────────────┐    │
│  │ Public Subnet    │  │ Private Subnet   │    │
│  │  ┌────────────┐  │  │  ┌────────────┐  │    │
│  │  │ NIC1       │  │  │  │ NIC2       │  │    │
│  │  │ (DHCP)     │◄─┼──┼──┤ (DHCP)     │  │    │
│  │  │ PublicWAN  │  │  │  │ PrivateWAN │  │    │
│  │  │ S/D: ON    │  │  │  │ S/D: OFF   │  │    │
│  │  └────────────┘  │  │  └────────────┘  │    │
│  │      ▲           │  │        ▲         │    │
│  └──────┼───────────┘  └────────┼─────────┘    │
│         │  ZTNA Connector EC2   │              │
│         └───────────────────────┘              │
└─────────────────────────────────────────────────┘
```

## Important Notes

- **Source/Destination Check**:
  - 1-NIC: Disabled (allows routing)
  - 2-NIC: NIC1 enabled, NIC2 disabled
- **Security Group**: Default allows all egress, no ingress (unless specified)
- **IP Assignment**: Both NICs use DHCP by default (can be set to static)
- **User Data**: The template uses YAML format matching CloudFormation templates
- **AMI Selection**: Automatically selects regional AMI unless custom AMI specified

## Comparison with OCI/Azure Templates

This AWS template mirrors the OCI/Azure template structure with the following key mappings:

| Concept | OCI | Azure | AWS |
|---------|-----|-------|-----|
| Virtual Network | VCN | VNet | VPC |
| Subnet | Subnet OCID | Subnet ID | Subnet ID |
| Network Interface | VNIC | NIC | ENI (Network Interface) |
| Compute | Instance | VM | EC2 Instance |
| Image | Custom Image / Marketplace | Marketplace Plan / Custom | AMI (Regional Map / Custom) |
| Availability | Availability Domain | Availability Zone/Set | Availability Zone |
| Bootstrap | Metadata | Custom Data | User Data |
| Tags | Freeform Tags | Tags | Tags |

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

## Troubleshooting

### AMI Not Found
If you get an AMI not found error, ensure you've updated the `regional_ami_map` in [`variables.tf`](variables.tf) with valid AMI IDs for your region, or use a custom AMI:

```hcl
use_custom_ami = true
custom_ami_id  = "ami-your-custom-ami-id"
```

### Source/Destination Check
The template automatically configures source/destination checks correctly:
- 1-NIC: Disabled to allow routing
- 2-NIC NIC1: Enabled (PublicWAN)
- 2-NIC NIC2: Disabled (PrivateWAN for routing)

## Support

This template is based on the AWS CloudFormation templates:
- 1-NIC: `AWS-PA-ZTNA-Connector-1ARM.yaml`
- 2-NIC: `AWS-PA-ZTNA-Connector-2ARM.yaml`

For issues or questions, refer to the Palo Alto Networks documentation for ZTNA Connector deployment.
