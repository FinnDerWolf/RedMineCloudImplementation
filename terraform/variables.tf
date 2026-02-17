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

variable "worker_flavor" {
  type = string
}
variable "server_flavor" {
  type = string
}

# Storage
variable "worker_volume_size" {
  type = number
}
variable "server_volume_size" {
  type = number
}

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

variable "dns_nameservers" {
  type        = list(string)
  description = "DNS servers for the subnet (Neutron DHCP)"
  default     = ["10.33.16.100", "1.1.1.1"]
}

