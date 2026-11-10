# Creating an Azure Virtual Machine with Nginx web server

This task involves defining additional resources, using provisioners to install software and configure the VM, and utilizing Terraform datasources.

## Prerequisites

- Basic understanding of Terraform and Azure.
- Terraform installed on your machine.
- Azure CLI installed and configured.

## Hands-on Task
1. Fork this repository.
2. Create a resource group manually in the Azure portal.
3. Retrieve the information from the resource group using a datasource for `azurerm_virtual_network`, `azurerm_network_interface`, `azurerm_subnet`, and `azurerm_virtual_machine`.
4. Create a default page for Nginx.
5. Use the `remote-exec` provisioner to install Nginx.
6. Use the `file` provisioner to pass the default page for Nginx.
7. Plan and apply Terraform changes using the `tfplan` file.
8. Separate the code between `provider.tf`, `variables.tf`, and `datasources.tf`.

## Run the two configurations

Create the resource group in Azure Portal before running Terraform. The root
configuration reads the existing VNet, subnet, network interface, and Linux VM
from that group. Set their names in a local tfvars file if they differ from the
defaults in variables.tf.

If those resources do not exist yet, create them with the independent
configuration in infrastructure/. Set ssh_source_cidr to the Terraform client's
public IPv4 address with a /32 suffix, and set ssh_private_key_path to the RSA
key whose public counterpart has the same filename with a .pub suffix. Set
location and vm_size if the defaults are unavailable in your subscription.

    terraform -chdir=infrastructure init
    terraform -chdir=infrastructure plan -out=tfplan
    terraform -chdir=infrastructure apply tfplan

From the repository root, set ssh_private_key_path for the existing VM's SSH
key and run the provisioning configuration. The VM needs a public IP reachable
over SSH from the Terraform client.

    terraform init
    terraform plan -out=tfplan
    terraform apply tfplan
    terraform output -raw nginx_url
