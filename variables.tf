variable "prefix" {
  description = "Prefix for the Azure resources created by Terraform."
  type        = string
  default     = "tfvmex"
}

variable "resource_group_name" {
  description = "Name of the resource group created manually in Azure Portal."
  type        = string
  default     = "tfvmex-resources"
}

variable "vm_size" {
  description = "Azure VM size available in the deployment region."
  type        = string
  default     = "Standard_DS1_v2"
}

variable "ssh_private_key_path" {
  description = "Path to the local SSH private key. Its public key must be at the same path with a .pub suffix."
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "ssh_source_cidr" {
  description = "Public IPv4 address of the machine running Terraform, in /32 CIDR notation."
  type        = string
  nullable    = false

  validation {
    condition     = can(cidrnetmask(var.ssh_source_cidr)) && endswith(var.ssh_source_cidr, "/32")
    error_message = "Use one public IPv4 address in /32 CIDR notation."
  }
}

variable "location" {
  description = "Optional Azure region for the VM and network. Defaults to the resource group's region."
  type        = string
  default     = null
}
