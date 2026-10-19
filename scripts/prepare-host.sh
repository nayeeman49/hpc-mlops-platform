#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -eq 0 ]]; then
  echo "Run this as your normal user. It will call sudo itself." >&2
  exit 1
fi

sudo apt-get update
sudo apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients virtinst genisoimage cloud-image-utils
sudo usermod -aG libvirt,kvm "${USER}"

sudo mkdir -p /var/lib/libvirt/hpc-lab
sudo chown libvirt-qemu:libvirt-qemu /var/lib/libvirt/hpc-lab
sudo chmod 0755 /var/lib/libvirt/hpc-lab

echo
echo "Packages are installed and the storage directory is ready."
echo "If 'virsh -c qemu:///system list --all' says permission denied, log out and back in so the libvirt group applies."
virsh -c qemu:///system list --all || true
