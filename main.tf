resource "terraform_data" "nginx" {
  triggers_replace = [
    data.azurerm_virtual_machine.main.id,
    filesha256("${path.module}/index.html"),
  ]

  connection {
    type        = "ssh"
    host        = data.azurerm_virtual_machine.main.public_ip_address
    user        = var.admin_username
    private_key = sensitive(file(pathexpand(var.ssh_private_key_path)))
  }

  provisioner "file" {
    source      = "${path.module}/index.html"
    destination = "/home/${var.admin_username}/terraform-nginx-index.html"
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
