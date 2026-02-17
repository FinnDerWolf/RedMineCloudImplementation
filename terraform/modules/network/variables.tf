variable "network_name" {
  description = "Name des Neutron-Netzwerks"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR des Subnetzes"
  type        = string
}

variable "dns_nameservers" {
  type        = list(string)
  default     = ["10.33.16.100", "1.1.1.1"]
}
