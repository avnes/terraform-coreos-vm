# terraform-coreos-vm

Used to create kvm/qemu/libvirt VMs with Fedora CoreOS server through automation using Terraform. These will eventually be used to power my Kubernetes playground at home.


## Requirements

### Install virtualization software

Please note that these instructions are written for Fedora and CentOS Stream:

```bash
sudo dnf install libvirt cockpit cockpit-machines virt-manager coreos-installer
sudo systemctl enable cockpit.socket --now
sudo systemctl enable libvirtd --now
sudo firewall-cmd --zone=public --add-service=cockpit --permanent
sudo firewall-cmd --reload
```

### Download base image

```bash
coreos-installer download -p qemu -f qcow2.xz --decompress
sudo mv fedora-coreos-*.qcow2 /var/lib/libvirt/images/fedora-coreos.qcow2
```

Assuming /var/lib/libvirt/images/ is the location of the default pool you want to use.

### Install Terraform

```bash
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
sudo dnf install -y terraform
```

### Allow using libvirt

You will need to add your regular Linux user to be able to use libvirt:

```bash
sudo usermod -a -G libvirt $(whoami)
```

Now logout, and login again to activate your membership in the libvirt group.

## Create VMs with terraform

### Define variables

Create a file called terraform.tfvars with content similar to this:

```hcl
project_name = "coreos"

network_name = "bridged-network"

nodes = {
  "master" = {
    name      = "dev-node02",
    ip        = "10.0.1.11/23"
    gateway   = "10.0.0.1"
    dns       = "10.0.0.1,8.8.8.8,8.8.4.4"
    interface = "enp0s3"
    keymap    = "dk"
    vcpu      = 1,
    memory    = "2048",
    disk_pool = "default",
    disk_size = "12000000000",
    mac       = "52:54:11:22:33:44",
  },
}
```

If you want to use a remote backend to store the state, also create a file called backend.tf.

More info about Terraform backends at <https://www.terraform.io/docs/language/settings/backends/>

```bash
cd terraform-coreos-vm
terraform init  # Or: terraform init -backend-config=/path-to/backend.tf
terraform apply # Or: terraform apply -var-file=/path-to/terraform.tfvars
```
