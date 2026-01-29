terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}

resource "openstack_blockstorage_volume_v3" "volume" {
  count = var.instance_count

  name     = "${var.name_prefix}-volume-${count.index}"
  size     = var.volume_size
  image_id = var.image_id
}


resource "openstack_networking_port_v2" "port" {
  count      = var.instance_count
  name       = "${var.name_prefix}-port-${count.index}"
  network_id = var.network_id

  fixed_ip {
    subnet_id = var.subnet_id
  }

  security_group_ids = var.security_group_ids
}


resource "openstack_compute_instance_v2" "vm" {
  count       = var.instance_count
  name        = "${var.name_prefix}-${count.index}"
  flavor_name = var.flavor
  key_pair = var.keypair_name

  network {
    port = openstack_networking_port_v2.port[count.index].id
  }

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.volume[count.index].id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }
}

