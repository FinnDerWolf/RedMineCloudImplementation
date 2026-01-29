output "control_plane_floating_ip" {
  value = openstack_networking_floatingip_v2.control_fip.address
}

output "control_plane_private_ip" {
  value = module.control_plane.private_ips[0]
}

output "worker_private_ips" {
  value = module.workers.private_ips
}

