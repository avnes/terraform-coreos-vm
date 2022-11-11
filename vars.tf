variable "project_name" {
  type        = string
  default     = null
  description = "The project name is used for grouping the VMs"
}

variable "disk_pool" {
  type        = string
  default     = "default"
  description = "The name of the libvirt image disk pool"
}

variable "network_name" {
  type        = string
  default     = "default"
  description = "The name of the libvirt network"
}

variable "wait_for_lease" {
  type        = bool
  default     = false
  description = "Wait until the network interface gets a DHCP lease from libvirt, so that the computed IP addresses will be available when the domain is up and the plan applied."
}

variable "autostart" {
  type        = bool
  default     = true
  description = "Start virtual machine when host machine boots."
}

variable "nodes" {
  type        = map(any)
  default     = {}
  description = "A map of maps with server details. Please see example in README"
}
