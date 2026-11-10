data "azurerm_virtual_network" "main" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "internal" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

data "azurerm_network_interface" "main" {
  name                = var.network_interface_name
  resource_group_name = var.resource_group_name
}

data "azurerm_virtual_machine" "main" {
  name                = var.virtual_machine_name
  resource_group_name = var.resource_group_name
}
