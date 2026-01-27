[General]
model = ion 200v
host1_name = locator.cgnx.net

[License]
key = ${license_key}
secret = ${license_secret}

[1]
role = PublicWAN
type = DHCP

[2]
role = PrivateWAN
type = STATIC
address = ${dc_lan_port_ip}
gateway = ${dc_lan_port_gateway}
dns1 = ${dc_lan_port_dns}