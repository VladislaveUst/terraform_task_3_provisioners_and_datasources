data "azurerm_resource_group" "example" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "main" {
  name                = azurerm_virtual_network.main.name
  resource_group_name = data.azurerm_resource_group.example.name
}

data "azurerm_subnet" "internal" {
  name                 = azurerm_subnet.internal.name
  virtual_network_name = data.azurerm_virtual_network.main.name
  resource_group_name  = data.azurerm_resource_group.example.name
}

data "azurerm_network_interface" "main" {
  name                = azurerm_network_interface.main.name
  resource_group_name = data.azurerm_resource_group.example.name
}

data "azurerm_virtual_machine" "main" {
  name                = azurerm_linux_virtual_machine.main.name
  resource_group_name = data.azurerm_resource_group.example.name
}
