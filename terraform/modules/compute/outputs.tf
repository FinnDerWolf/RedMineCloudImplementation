# Gibt die IPv4 Fixed IPs der Instanzen zurück.
output "private_ips" {
  value = [
    for vm in openstack_compute_instance_v2.vm :
    try(vm.network[0].fixed_ip_v4, null)
  ]
}

# Port IDs werden u.a. für Floating-IP-Assoziation genutzt.
output "port_ids" {
  value = [for p in openstack_networking_port_v2.port : p.id]
}



