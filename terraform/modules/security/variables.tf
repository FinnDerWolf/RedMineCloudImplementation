variable "sg_name" {
  description = "Name der Security Group"
  type        = string
}
variable "allowed_ports" {
  type = list(number)
  description = "Liste erlaubter TCP-Ports (Ingress)"
}
variable "remote_cidr" {
  description = "CIDR, aus dem Ingress erlaubt ist"
  type        = string
}
