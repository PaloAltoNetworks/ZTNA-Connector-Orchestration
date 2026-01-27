# Palo Alto Networks ZTNA Connector Module Example

A Terraform module example for deploying a two-armed ZTNA Connector VM instance in GCP in the FedRAMP environment.

## Reference
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 2.0 |

### Providers

No providers.

### Modules

No modules.

### Resources

No resources.

## Usage
1. Access Google Cloud Shell or any other environment that has access to your GCP project
2. Modify the variables in `terraform.tfvars`.


There following variables have no default varules and must be set per deployment:
 - `project_id`
 - `region`
 - `zone`
 - `vm_name`
 - `vm_internet_subnet`
 - `vm_data_center_subnet`
 - `vm_license_key`
 - `vm_license_secret`


1. Apply the terraform code:

```
terraform init
terraform apply 
```

2. Check the output plan and confirm the apply.

3. Check the successful application and outputs of the resulting infrastructure:

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project name to deploy the ZTNA Connector in to. | `string` | `null` | yes |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | The VM Instance name for the ZTNA Connector. | `string` | `null` | yes |
| <a name="input_vm_internet_subnet"></a> [vm\_internet\_subnet](#input\_vm\_internet\_subnet) | The Internet accessible subnet name to deploy the ZTNA Connector in to. | `string` | `null` | yes |
| <a name="input_vm_data_center_subnet"></a> [vm\_data\_center\_subnet](#input\_vm\_data\_center\_subnet) | The Data Center accessible subnet name to deploy the ZTNA Connector in to. | `string` | `null` | yes |
| <a name="input_vm_license_key"></a> [vm\_license\_key](#input\_vm\_license\_key) | The ZTNA Connector License Key for the Connector. | `string` | `null` | yes |
| <a name="input_vm_license_secret"></a> [vm\_license\_secret](#input\_vm\_license\_secret) | ZTNA Connector License Secret for the Connector. | `string` | `null` | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP Region to deploy the ZTNA Connector in to. | `string` | `null` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | The GCP Zone within the GCP Region to deploy the ZTNA Connector in to. | `string` | `null` | no |

### Outputs

No outputs.

