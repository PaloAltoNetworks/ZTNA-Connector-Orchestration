# OCI ZTNA Connector Deployment

A Terraform template for deploying Palo Alto Networks ZTNA (Zero Trust Network Access) Connector on Oracle Cloud Infrastructure (OCI).

## Overview

This template deploys a single-arm ZTNA Connector instance in OCI using either marketplace or custom images. The connector provides secure remote access capabilities for Prisma Access SASE services.

## Prerequisites

- OCI account with appropriate permissions
- Terraform >= 1.5.0
- OCI provider >= 6.30
- ZTNA Connector license key and secret
- Existing VCN and subnet

## Quick Start

1. **Clone and configure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

2. **Required variables**:
   - `compartment_ocid` - Target compartment
   - `number_of_nics` - Number of network interfaces "1" or "2"
   - `internet_subnet_id` - Existing internet facing subnet OCID
   - `data_center_subnet_id` - Existing data center facing subnet OCID needed if number_of_nics == "2"
   - `vm_license_key` - ZTNA license key
   - `vm_license_secret` - ZTNA license secret

## Architecture

- **Instance**: VM.Standard.E5.Flex (2 OCPUs, 16GB RAM)
- **Network**: Single private interface (no public IP)
- **Image**: Marketplace or custom ZTNA Connector image
- **Model**: ION 200v

## Configuration

The connector is automatically configured via cloud-init with the provided license credentials.

## Outputs

- `instance_id` - Compute instance OCID
- `instance_private_ip` - Private IP address
- `internet_subnet_id` - Subnet OCID
- `data_center_subnet_id` - Subnet OCID

## Support

For marketplace deployments, subscription and EULA acceptance are handled automatically.

## Test
- zip the contents of this directory using `zip ztna-conn-1-arm-mp-listing.zip *.tf`
- use the ztna-conn-1-arm-mp-listing.zip file to bring up the stack on OCI
