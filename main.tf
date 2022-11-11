provider "libvirt" {
  uri = "qemu:///system"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "local_sensitive_file" "ssh_private_key" {
  content         = tls_private_key.private_key.private_key_pem
  filename        = pathexpand("~/.ssh/${var.project_name}.pem")
  file_permission = "0600"
}

resource "local_file" "ssh_public_key" {
  content         = tls_private_key.private_key.public_key_openssh
  filename        = pathexpand("~/.ssh/${var.project_name}.pub")
  file_permission = "0644"
}

resource "random_password" "password" {
  length  = 8
  special = false
}

resource "libvirt_volume" "node_volume" {
  for_each         = var.nodes
  name             = "${each.value.name}.qcow2"
  base_volume_name = "fedora-coreos.qcow2"
  pool             = each.value.disk_pool
  format           = "qcow2"
  size             = each.value.disk_size
}

data "ignition_user" "user" {
  name                = "core"
  groups              = ["docker", "wheel", "sudo"]
  password_hash       = bcrypt(random_password.password.result)
  ssh_authorized_keys = [tls_private_key.private_key.public_key_openssh]
}

data "ignition_systemd_unit" "iscsi" {
  name    = "iscsi.service"
  enabled = true
}

data "ignition_file" "keymap" {
  for_each = var.nodes
  path     = "/etc/vconsole.conf"
  mode     = 0644
  content {
    content = "KEYMAP=${each.value.keymap}"
  }
}

data "ignition_file" "hostname" {
  for_each = var.nodes
  path     = "/etc/hostname"
  mode     = 0420
  content {
    content = each.value.name
  }
}

data "ignition_file" "networkmanager" {
  for_each  = var.nodes
  path      = "/etc/NetworkManager/system-connections/${each.value.interface}.nmconnection"
  mode      = 0600
  overwrite = true
  content {
    content = <<EOT
[connection]
type=ethernet
id="Wired connection 1"
interface-name=${each.value.interface}

[ipv4]
method=manual
addresses=${each.value.ip}
gateway=${each.value.gateway}
dns=${each.value.dns}
EOT
  }
}

data "ignition_config" "config" {
  for_each = var.nodes
  users    = [data.ignition_user.user.rendered]
  systemd  = [data.ignition_systemd_unit.iscsi.rendered]
  files = [
    data.ignition_file.hostname[each.key].rendered,
    data.ignition_file.networkmanager[each.key].rendered,
    data.ignition_file.keymap[each.key].rendered
  ]
}

resource "libvirt_ignition" "ignition" {
  for_each = var.nodes
  name     = "${each.value.name}-ignition"
  content  = data.ignition_config.config[each.key].rendered
}

resource "libvirt_domain" "domain" {
  for_each        = var.nodes
  name            = each.value.name
  memory          = each.value.memory
  vcpu            = each.value.vcpu
  autostart       = var.autostart
  coreos_ignition = libvirt_ignition.ignition[each.key].id

  network_interface {
    network_name   = var.network_name
    hostname       = each.value.name
    mac            = each.value.mac
    wait_for_lease = var.wait_for_lease
  }

  disk {
    volume_id = element(libvirt_volume.node_volume[each.key].*.id, 1)
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
  }
}
