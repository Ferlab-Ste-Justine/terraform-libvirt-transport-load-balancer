terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = ">= 0.6.14, <= 0.7.1"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = ">= 2.0.0, < 3.0.0"
    }
  }
  required_version = ">= 1.3.0"
}
