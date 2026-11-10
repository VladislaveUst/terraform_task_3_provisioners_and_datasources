locals {
  deployment_location = coalesce(var.location, data.azurerm_resource_group.example.location)
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = local.deployment_location
  resource_group_name = data.azurerm_resource_group.example.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]

  lifecycle {
    replace_triggered_by = [azurerm_virtual_network.main.location]
  }
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-ip"
  resource_group_name = data.azurerm_resource_group.example.name
  location            = local.deployment_location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = local.deployment_location
  resource_group_name = data.azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = local.deployment_location
  resource_group_name = data.azurerm_resource_group.example.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.ssh_source_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_linux_virtual_machine" "main" {
  name                              = "${var.prefix}-vm"
  location                          = local.deployment_location
  resource_group_name               = data.azurerm_resource_group.example.name
  network_interface_ids             = [azurerm_network_interface.main.id]
  size                              = var.vm_size
  admin_username                    = "testadmin"
  disable_password_authentication   = true
  vm_agent_platform_updates_enabled = true

  admin_ssh_key {
    username   = "testadmin"
    public_key = file("${pathexpand(var.ssh_private_key_path)}.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    environment = "staging"
  }

  depends_on = [azurerm_network_interface_security_group_association.main]
}

resource "terraform_data" "nginx" {
  triggers_replace = [
    azurerm_linux_virtual_machine.main.virtual_machine_id,
    filesha256("${path.module}/index.html"),
  ]

  connection {
    type        = "ssh"
    host        = data.azurerm_virtual_machine.main.public_ip_address
    user        = azurerm_linux_virtual_machine.main.admin_username
    private_key = sensitive(file(pathexpand(var.ssh_private_key_path)))
  }

  provisioner "file" {
    source      = "${path.module}/index.html"
    destination = "/home/${azurerm_linux_virtual_machine.main.admin_username}/terraform-nginx-index.html"
  }

  provisioner "remote-exec" {
    inline = [
      "set -eu",
      "sudo apt-get -o Acquire::Retries=3 update",
      "sudo env DEBIAN_FRONTEND=noninteractive apt-get -o DPkg::Lock::Timeout=120 -o Acquire::Retries=3 install -y nginx",
      "sudo install -m 0644 \"$HOME/terraform-nginx-index.html\" /var/www/html/index.html",
      "sudo nginx -t",
      "sudo systemctl enable --now nginx",
    ]
  }
}

output "nginx_url" {
  description = "URL of the Nginx default page."
  value       = "http://${data.azurerm_virtual_machine.main.public_ip_address}/"
  depends_on  = [terraform_data.nginx]
}

output "azure_resource_ids" {
  description = "Resource IDs retrieved by the Azure data sources."
  value = {
    virtual_network   = data.azurerm_virtual_network.main.id
    subnet            = data.azurerm_subnet.internal.id
    network_interface = data.azurerm_network_interface.main.id
    virtual_machine   = data.azurerm_virtual_machine.main.id
  }
}
