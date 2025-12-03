# When there is a new ZTNA connector version / CSP template update in the AWS marketplace
# the "AWS-PA-ZTNA-Connector-1ARM-Autoscale.yaml" file needs to be downloaded and updated with additional arguments as per
# https://confluence.paloaltonetworks.local/display/HSH/Aws+Deploy+using+Csp+template to add CgnxHostName, CgnxHostIp, BlockDeviceMappings
# in parameters and host1_name and host1_ip in UserData
# Also change AllowedValues under MyASGNWBWPercent to allow 10,20,30,40

locals {
  data_raw = yamldecode(file("${path.cwd}/../../tf_data_aws.yaml"))
  meta_data_raw = yamldecode(file("${path.cwd}/../metadata_aws_1_arm_csp_autoscale.yaml"))
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
      host1_ip = local.meta_data_raw.General.host1_ip
      host1_name: local.meta_data_raw.General.host1_name
      host2_ip: local.meta_data_raw.General.host2_ip
      host2_name: local.meta_data_raw.General.host2_name
      host3_ip: local.meta_data_raw.General.host3_ip
      host3_name: local.meta_data_raw.General.host3_name
      host4_ip: local.meta_data_raw.General.host4_ip
      host4_name: local.meta_data_raw.General.host4_name
      key = local.data_raw.vpc.instance_details.key
      secret = local.data_raw.vpc.instance_details.secret
  }
  autoscale_data={
    min_size = local.data_raw.autoscale.min_size
    max_size = local.data_raw.autoscale.max_size
    bw_percent = local.data_raw.autoscale.bw_percent
  }
}

provider "aws" {
  access_key = local.provider_data.provider_access_key
  secret_key = local.provider_data.provider_secret_key
  region     = local.provider_data.provider_region
}

resource "aws_cloudformation_stack" "ztna_connector_1arm_autoscale" {
  name = local.instance_data.name

  parameters = {
    IONKey = local.instance_data.key
    IONSecret = local.instance_data.secret
    MyVPC = local.subnet_data.vpc
    PrivateSubnet = local.subnet_data.external_subnet
    CgnxHostName = local.instance_data.host1_name
    CgnxHostIp = local.instance_data.host1_ip
    CgnxHost2Name = local.instance_data.host2_name
    CgnxHost2Ip = local.instance_data.host2_ip
    CgnxHost3Name = local.instance_data.host3_name
    CgnxHost3Ip = local.instance_data.host3_ip
    CgnxHost4Name = local.instance_data.host4_name
    CgnxHost4Ip = local.instance_data.host4_ip
    MyASGMinSize = local.autoscale_data.min_size
    MyASGMaxSize = local.autoscale_data.max_size
    MyASGNWBWPercent = local.autoscale_data.bw_percent
  }

  template_body = file("${path.cwd}/../AWS-PA-ZTNA-Connector-1ARM-Autoscale-auto1.yaml")

  tags = {
    "Name" = local.instance_data.name
    "no-shut-contact" = "hshah1@paloaltonetworks.com"
  }

  timeouts {
    delete = "70m"
  }

}