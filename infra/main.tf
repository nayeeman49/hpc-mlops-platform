locals {
  nodes = merge(
    {
      head = {
        role      = "controller"
        vcpu      = var.head_vcpu
        memory_mb = var.head_memory_mb
      }
    },
    {
      for index in range(var.compute_count) :
      "compute${index + 1}" => {
        role      = "compute"
        vcpu      = var.compute_vcpu
        memory_mb = var.compute_memory_mb
      }
    }
  )
}

resource "libvirt_pool" "cluster" {
  name = "hpc-lab"
  type = "dir"

  target {
    path = "/var/lib/libvirt/hpc-lab"
  }
}

resource "libvirt_volume" "base" {
  name   = "ubuntu-26.04-base.qcow2"
  pool   = libvirt_pool.cluster.name
  source = var.base_image_url
  format = "qcow2"
}

resource "libvirt_network" "cluster" {
  name      = "hpc-net"
  mode      = "nat"
  domain    = var.dns_domain
  addresses = [var.network_cidr]
  autostart = true

  dns {
    enabled    = true
    local_only = false
  }

  dhcp {
    enabled = true
  }
}

module "node" {
  source   = "../modules/vm"
  for_each = local.nodes

  name            = each.key
  role            = each.value.role
  vcpu            = each.value.vcpu
  memory_mb       = each.value.memory_mb
  disk_size_bytes = var.disk_size_gb * 1024 * 1024 * 1024
  pool_name       = libvirt_pool.cluster.name
  base_volume_id  = libvirt_volume.base.id
  network_id      = libvirt_network.cluster.id
  ssh_public_key  = var.ssh_public_key
  ssh_user        = var.ssh_user
  dns_domain      = var.dns_domain
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content = templatefile("${path.module}/templates/inventory.ini.tftpl", {
    nodes      = { for name, node in module.node : name => { role = local.nodes[name].role, ip = node.ip } }
    ssh_user   = var.ssh_user
    gpu_name   = var.gpu_inventory_name
    dns_domain = var.dns_domain
  })
}
