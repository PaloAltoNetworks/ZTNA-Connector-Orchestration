# When there is a new ZTNA connector version / CSP template update in the AWS marketplace
# the "AWS-PA-ZTNA-Connector-2ARM.yaml" file needs to be downloaded and updated with additional arguments as per
# https://confluence.paloaltonetworks.local/display/HSH/Aws+Deploy+using+Csp+template to add CgnxHostName, CgnxHostIp
# in parameters and host1_name and host1_ip in UserData

locals {
  data_raw = yamldecode(file("${path.cwd}/../../tf_data_aws.yaml"))
  provider_data = {
      provider_name = local.data_raw.provider.name
      provider_region = local.data_raw.provider.region
      provider_access_key = local.data_raw.provider.access_key
      provider_secret_key = local.data_raw.provider.secret_key
  }
  subnet_data={
      vpc = local.data_raw.vpc.vpc_id
      external_subnet = local.data_raw.vpc.external
      internal_subnet = local.data_raw.vpc.internal
      sg = local.data_raw.vpc.sg
  }
  instance_data={
      name = local.data_raw.vpc.instance_details.name
      host1_name = local.data_raw.vpc.instance_details.host1_name
      host1_ip = local.data_raw.vpc.instance_details.host1_ip
      key = local.data_raw.vpc.instance_details.key
      secret = local.data_raw.vpc.instance_details.secret
  }
}

provider "aws" {
  access_key = local.provider_data.provider_access_key
  secret_key = local.provider_data.provider_secret_key
  region     = local.provider_data.provider_region
}

resource "aws_cloudformation_stack" "ztna_connector_1arm" {
  name = local.instance_data.name

  parameters = {
    InstanceName = local.instance_data.name
    IONKey = local.instance_data.key
    IONSecret = local.instance_data.secret
    MyVPC = local.subnet_data.vpc
    PrivateSubnet = local.subnet_data.external_subnet
    CgnxHostName = local.instance_data.host1_name
    CgnxHostIp = local.instance_data.host1_ip
  }

  template_body = file("${path.cwd}/../AWS-PA-ZTNA-Connector-1ARM.yaml")

  tags = {
    "Name" = local.instance_data.name
    "no-shut-contact" = "hshah1@paloaltonetworks.com"
  }

}