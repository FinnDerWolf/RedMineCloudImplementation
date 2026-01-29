# OpenStack Zugang
variable "auth_url" {}
variable "project" {}
variable "user" {}
variable "password" { sensitive = true }
variable "region" {}

# Netzwerk
variable "network_name" {}
variable "subnet_cidr" {}

# Image / Flavors
variable "image_id" {
  type = string
}

variable "worker_flavor" {}
variable "server_flavor" {}

# Storage
variable "worker_volume_size" {}
variable "server_volume_size" {}

# Externes Netz (Floating IP Pool)
variable "external_network_name" {
  type = string
}

# Existierender Router 
variable "existing_router_id" {
  type = string
}

# CIDR  Uni-VPN 
variable "uni_vpn_cidr" {
  type = string
}

variable "ssh_public_key_path" {
  type = string
}


