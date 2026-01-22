variable "instance_count" {}
variable "name_prefix" {}
#variable "image_name" {}
variable "flavor" {}
variable "network_id" {}
variable "image_id" {
  type = string
}
variable "security_groups" {
  type = list(string)
}
variable "volume_size" {}
