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

variable "redmine_flavor" {}
variable "db_flavor" {}

# Storage
variable "redmine_volume_size" {}
variable "db_volume_size" {}
