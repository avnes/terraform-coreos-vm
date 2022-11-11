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
