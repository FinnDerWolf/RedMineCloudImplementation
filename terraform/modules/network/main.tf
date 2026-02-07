terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}

resource "openstack_networking_network_v2" "net" {
  name = var.network_name
}

resource "openstack_networking_subnet_v2" "subnet" {
  name         = "${var.network_name}-subnet"
  network_id   = openstack_networking_network_v2.net.id
  cidr         = var.subnet_cidr
  ip_version   = 4
  enable_dhcp  = true

  dns_nameservers = var.dns_nameservers
}

