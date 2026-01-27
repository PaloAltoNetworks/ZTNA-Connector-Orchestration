# Data source for the resource group
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# Data source for existing VNet (when using existing)
data "azurerm_virtual_network" "existing" {
  count               = var.vnet_new_or_existing == "existing" ? 1 : 0
  name                = var.virtual_network_name
  resource_group_name = local.vnet_resource_group_name
}

# Data source for existing subnet1 (when using existing VNet)
data "azurerm_subnet" "subnet1" {
  count                = var.vnet_new_or_existing == "existing" ? 1 : 0
  name                 = var.subnet1_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = local.vnet_resource_group_name
}

# Data source for existing subnet2 (when using existing VNet with 2 NICs)
data "azurerm_subnet" "subnet2" {
  count                = var.vnet_new_or_existing == "existing" && var.number_of_nics == "2" ? 1 : 0
  name                 = var.subnet2_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = local.vnet_resource_group_name
}
