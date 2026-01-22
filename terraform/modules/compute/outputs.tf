output "private_ips" {
  value = [for vm in openstack_compute_instance_v2.vm : vm.network[0].fixed_ip_v4]
}
