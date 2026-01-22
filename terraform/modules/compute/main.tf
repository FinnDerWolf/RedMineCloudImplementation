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


resource "openstack_compute_instance_v2" "vm" {
  count       = var.instance_count
  name        = "${var.name_prefix}-${count.index}"
  flavor_name = var.flavor

  network {
    uuid = var.network_id
  }

  security_groups = var.security_groups

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.volume[count.index].id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }
}

