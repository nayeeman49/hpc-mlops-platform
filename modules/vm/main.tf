resource "libvirt_volume" "disk" {
  name           = "${var.name}.qcow2"
  pool           = var.pool_name
  base_volume_id = var.base_volume_id
  size           = var.disk_size_bytes
  format         = "qcow2"
}

resource "libvirt_cloudinit_disk" "init" {
  name = "${var.name}-init.iso"
  pool = var.pool_name
  user_data = templatefile("${path.module}/cloud-init/user-data.yaml.tftpl", {
    hostname = var.name
    fqdn     = "${var.name}.${var.dns_domain}"
    ssh_user = var.ssh_user
    ssh_key  = var.ssh_public_key
  })
}

resource "libvirt_domain" "node" {
  name       = var.name
  vcpu       = var.vcpu
  memory     = var.memory_mb
  cloudinit  = libvirt_cloudinit_disk.init.id
  autostart  = true
  qemu_agent = true

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    network_id     = var.network_id
    hostname       = var.name
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.disk.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type           = "vnc"
    listen_type    = "address"
    listen_address = "127.0.0.1"
    autoport       = true
  }
}
