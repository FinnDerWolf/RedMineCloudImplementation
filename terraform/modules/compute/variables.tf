variable "instance_count" {
  description = "Anzahl der zu erstellenden Instanzen"
  type        = number
}

variable "name_prefix" {
  description = "Prefix für Ressourcen-Namen"
  type        = string
}

variable "flavor" {
  description = "OpenStack Flavor (z.B. m1.medium)"
  type        = string
}

variable "network_id" {
  description = "Neutron Network ID"
  type        = string
}
variable "image_id" {
  type = string
  description = "Image UUID für Boot-Volumes"
}
variable "security_group_ids" {
  type = list(string)
  description = "Liste der Security Group IDs, die am Port hängen"
}

variable "volume_size" {
  description = "Größe des Boot-Volumes in GB"
  type        = number
}

variable "subnet_id" {
  type = string
  description = "Subnet ID für Fixed IP"
}

variable "keypair_name" {
  type = string
  description = "OpenStack Keypair Name (für SSH)"
}



