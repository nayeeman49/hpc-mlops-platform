# HPC lab on one workstation

Terraform builds a small KVM cluster on this machine. Ansible turns it into a Slurm site: CPU partitions on the VMs, and a GPU partition on the workstation so the RTX 4080 stays on the host.

```text
workstation (Ubuntu, slurmd, RTX 4080, Prometheus, Grafana)
└── libvirt NAT 10.10.0.0/24
    ├── head        slurmctld, slurmdbd, MariaDB, NFS, node_exporter
    ├── compute1    slurmd, node_exporter
    └── compute2    slurmd, node_exporter
```

The head and compute nodes are Ubuntu 26.04 cloud images, the same release family as a current workstation, so Slurm packages can match. The GPU node is the workstation itself. Ansible does not rename it. Slurm calls that node `gpuhost` and reaches it at the libvirt gateway `10.10.0.1`.

## Budget

| Node | vCPU | RAM | Disk |
| --- | ---: | ---: | --- |
| head | 2 | 4 GB | 16 GB thin |
| each compute | 4 | 6 GB | 16 GB thin |
| workstation | the rest | leave at least 24 GB free for GPU jobs | host filesystem |

`compute_count` is capped at 4. Two compute nodes use about 16 GB of RAM and 10 vCPUs.

## Layout

```text
infra/                 Terraform root for the VMs, local state
modules/vm/            one disk, cloud-init ISO, and domain
monitoring/            Terraform root for the Grafana datasource and dashboard
ansible/               generated inventory.ini, Slurm, and the monitoring stack
jobs/                  sample batch scripts
scripts/prepare-host.sh
```

Provider pin: `dmacvicar/libvirt` `~> 0.8.3`. The 0.9 provider uses a different schema.

## First VM

Run this on the workstation, from the repo root.

```bash
chmod +x scripts/prepare-host.sh
./scripts/prepare-host.sh
cp infra/terraform.tfvars.example infra/terraform.tfvars
# paste your SSH public key into infra/terraform.tfvars
# optional: set compute_count = 0 until the head node boots
cd infra
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
ssh ubuntu@<head-ip>
```

`ansible/inventory.ini` is written at the end of apply and is gitignored. State and `terraform.tfvars` are gitignored too.

After the head node accepts SSH, set `compute_count = 2` and apply again. The plan should add the compute nodes and leave the head node in place.

## Slurm

Change `slurm_db_password` in `ansible/group_vars/controller.yml` first.

```bash
cd ansible
ansible-playbook site.yml
```

The GPU play installs Slurm on the workstation and starts `slurmd`. It does not install or change the NVIDIA driver.

```bash
sinfo
sbatch ../jobs/cpu-hello.sbatch
sbatch ../jobs/gpu-smi.sbatch
sacct
```

`jobs/gpu-torch.sbatch` expects a `python3` environment on the workstation where `torch` can see CUDA. Install that yourself before submitting it.

## Monitoring

Ansible installs `prometheus-node-exporter` on every Slurm node and starts Prometheus and Grafana on the workstation with Docker. The containers use the host network, so Prometheus scrapes the VMs at their `10.10.0.0/24` addresses and the workstation at `127.0.0.1:9100`.

Set the same password in both files before the playbook:

- `ansible/group_vars/gpu.yml` → `grafana_admin_password`
- `monitoring/terraform.tfvars` → `grafana_admin_password` (copy from `monitoring/terraform.tfvars.example`)

Use at least 12 characters. The checked-in placeholder is rejected.

```bash
cd ~/Documents/hpc-mlops-platform/ansible
ansible-playbook site.yml
cd ../monitoring
terraform init
terraform apply
terraform output dashboard_url
```

`monitoring/` is a second state. It does not create the containers. The Grafana provider logs into `http://127.0.0.1:3000` and creates the folder `HPC lab`, the Prometheus datasource, and the dashboard `HPC lab nodes` from `monitoring/dashboards/nodes.json`. Open Grafana at `http://127.0.0.1:3000` on the workstation, or tunnel it:

```bash
ssh -L 3000:127.0.0.1:3000 nayeem@100.126.184.79
```

The dashboard shows which nodes are up, CPU, memory, root filesystem, and received network traffic. A later apply overwrites UI edits to that dashboard.

## Tear down

```bash
cd infra
terraform destroy
```

Destroy deletes the VMs, the network, and the storage pool. It does not remove Slurm packages from the workstation, and it does not stop Prometheus or Grafana. Stop those with `docker compose down` in `/opt/hpc-monitoring`, and stop `slurmd` on the host if you are finished with the GPU partition. `terraform -chdir=monitoring destroy` removes the Grafana folder, datasource, and dashboard.

## Limits

This stack uses local Terraform state. A second state for k3s, Helm, or MinIO waits until the Slurm demo works and there is still plenty of free disk. The cloud image is downloaded on the first apply.
