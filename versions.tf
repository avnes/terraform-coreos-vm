terraform {
  required_version = ">= 1.0.0"

  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }

    ignition = {
      source = "community-terraform-providers/ignition"
    }

    tls = {
      source = "hashicorp/tls"
    }

    local = {
      source = "hashicorp/local"
    }

    random = {
      source = "hashicorp/random"
    }
  }
}
