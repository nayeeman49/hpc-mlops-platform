variable "libvirt_uri" {
  description = "Libvirt connection URI. Apply this stack on the workstation."
  type        = string
  default     = "qemu:///system"
}

variable "ssh_public_key" {
  description = "Public key installed for the VM login user."
  type        = string

  validation {
    condition     = length(var.ssh_public_key) > 20
    error_message = "Set ssh_public_key in terraform.tfvars to an SSH public key."
  }
}

variable "ssh_user" {
  description = "Login user created by cloud-init on every VM."
  type        = string
  default     = "ubuntu"
}

variable "dns_domain" {
  description = "DNS domain served by the libvirt network."
  type        = string
  default     = "hpc.lab"
}

variable "network_cidr" {
  description = "IPv4 CIDR for the NAT lab network."
  type        = string
  default     = "10.10.0.0/24"
}

variable "base_image_url" {
  description = "Ubuntu cloud image downloaded once and used as the backing disk."
  type        = string
  default     = "https://cloud-images.ubuntu.com/releases/26.04/release/ubuntu-26.04-server-cloudimg-amd64.img"
}

variable "compute_count" {
  description = "Number of CPU compute VMs. Use 0 to bring up the head node alone."
  type        = number
  default     = 2

  validation {
    condition     = var.compute_count >= 0 && var.compute_count <= 4
    error_message = "compute_count must be between 0 and 4 on this workstation."
  }
}

variable "head_vcpu" {
  type    = number
  default = 2
}

variable "head_memory_mb" {
  type    = number
  default = 4096
}

variable "compute_vcpu" {
  type    = number
  default = 4
}

variable "compute_memory_mb" {
  type    = number
  default = 6144
}

variable "disk_size_gb" {
  description = "Maximum virtual disk size for each node. Disks are thin qcow2 copies."
  type        = number
  default     = 16
}

variable "gpu_inventory_name" {
  description = "Ansible inventory name for the bare-metal GPU node. This does not rename the workstation."
  type        = string
  default     = "gpuhost"
}
