output "network_id" {
  value = openstack_networking_network_v2.net.id
}

output "subnet_id" {
  value = openstack_networking_subnet_v2.subnet.id
}

