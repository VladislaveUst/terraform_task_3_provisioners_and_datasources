variable "resource_group_name" {
  description = "Name of the resource group created manually in Azure Portal."
  type        = string
  default     = "tfvmex-resources"
}

variable "virtual_network_name" {
  description = "Name of the existing Azure virtual network."
  type        = string
  default     = "tfvmex-network"
}

variable "subnet_name" {
  description = "Name of the existing subnet in the virtual network."
  type        = string
  default     = "internal"
}

variable "network_interface_name" {
  description = "Name of the existing VM network interface."
  type        = string
  default     = "tfvmex-nic"
}

variable "virtual_machine_name" {
  description = "Name of the existing Azure Linux virtual machine."
  type        = string
  default     = "tfvmex-vm"
}

variable "admin_username" {
  description = "SSH username on the existing virtual machine."
  type        = string
  default     = "testadmin"
}

variable "ssh_private_key_path" {
  description = "Path to the local private key used to connect to the VM over SSH."
  type        = string
  default     = "~/.ssh/id_rsa"
}
