variable "name" {
  type = string
}

variable "role" {
  type = string
}

variable "vcpu" {
  type = number
}

variable "memory_mb" {
  type = number
}

variable "disk_size_bytes" {
  type = number
}

variable "pool_name" {
  type = string
}

variable "base_volume_id" {
  type = string
}

variable "network_id" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "ssh_user" {
  type = string
}

variable "dns_domain" {
  type = string
}
