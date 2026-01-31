variable "network_name" {}
variable "subnet_cidr" {}

variable "dns_nameservers" {
  type        = list(string)
  default     = ["10.33.16.100", "1.1.1.1"]
}
