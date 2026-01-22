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

module "security_redmine" {
  source        = "./modules/security"
  sg_name       = "redmine-sg"
  allowed_ports = [22, 3000]   # SSH + Redmine intern
  remote_cidr  = var.subnet_cidr
  providers = {
    openstack = openstack
  }
}

module "security_db" {
  source        = "./modules/security"
  sg_name       = "db-sg"
  allowed_ports = [3306]       # MariaDB intern
  remote_cidr  = var.subnet_cidr
  providers = {
    openstack = openstack
  }
}

module "redmine" {
  source = "./modules/compute"

  instance_count  = 3
  name_prefix     = "redmine"
  image_id        = var.image_id
  flavor          = var.redmine_flavor
  volume_size     = var.redmine_volume_size
  network_id      = module.network.network_id
  security_groups = [module.security_redmine.sg_name]
}


module "database" {
  source = "./modules/compute"

  instance_count  = 2
  name_prefix     = "db"
  image_id        = var.image_id
  flavor          = var.db_flavor
  volume_size     = var.db_volume_size
  network_id      = module.network.network_id
  security_groups = [module.security_db.sg_name]
}

