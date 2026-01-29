terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}

provider "openstack" {
  auth_url    = var.auth_url
  tenant_name = var.project
  user_name   = var.user
  password    = var.password
  region      = var.region

  insecure    = true
}

module "network" {
  source       = "./modules/network"
  network_name = var.network_name
  subnet_cidr  = var.subnet_cidr
  providers = {
    openstack = openstack
  }
}

module "security_k8s_internal" {
  source        = "./modules/security"
  sg_name       = "k8s-internal-sg"
  allowed_ports = [22]              # intern SSH (für Jump + Admin)
  remote_cidr   = var.subnet_cidr   # nur aus dem privaten Subnetz
  providers = { openstack = openstack }
}

module "security_controlplane_public" {
  source        = "./modules/security"
  sg_name       = "k8s-controlplane-public-sg"
  allowed_ports = [22]              # SSH von außen
  remote_cidr   = var.uni_vpn_cidr  # Uni-VPN CIDR
  providers = { openstack = openstack }
}

module "control_plane" {
  source = "./modules/compute"

  instance_count      = 1
  name_prefix         = "k8s-control"
  image_id            = var.image_id
  flavor              = var.server_flavor
  volume_size         = var.server_volume_size
  network_id = module.network.network_id
  subnet_id  = module.network.subnet_id
  keypair_name = openstack_compute_keypair_v2.k8s.name
  security_group_ids  = [
    module.security_k8s_internal.sg_id,
    module.security_controlplane_public.sg_id
  ]
}

module "workers" {
  source = "./modules/compute"

  instance_count      = 3
  name_prefix         = "k8s-worker"
  image_id            = var.image_id
  flavor              = var.worker_flavor
  volume_size         = var.worker_volume_size
  network_id = module.network.network_id
  subnet_id  = module.network.subnet_id
  keypair_name = openstack_compute_keypair_v2.k8s.name
  security_group_ids  = [module.security_k8s_internal.sg_id]
}

resource "openstack_networking_router_interface_v2" "router_if" {
  router_id = var.existing_router_id
  subnet_id = module.network.subnet_id
}

data "openstack_networking_network_v2" "external" {
  name = var.external_network_name
}

resource "openstack_networking_floatingip_v2" "control_fip" {
  pool = data.openstack_networking_network_v2.external.name
}

resource "openstack_networking_floatingip_associate_v2" "control_fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.control_fip.address
  port_id     = module.control_plane.port_ids[0]

  depends_on = [openstack_networking_router_interface_v2.router_if]
}

resource "openstack_compute_keypair_v2" "k8s" {
  name       = "uni-k8s-key"
  public_key = file(var.ssh_public_key_path)
}



