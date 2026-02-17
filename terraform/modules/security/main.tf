terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}
resource "openstack_networking_secgroup_v2" "sg" {
  name = var.sg_name
}

resource "openstack_networking_secgroup_rule_v2" "ingress" {
  # Erstellt pro Port eine Ingress-Regel. toset()+tostring() sorgt dafür,
  # dass Terraform eindeutige Schlüssel hat.
  for_each = toset([for p in var.allowed_ports : tostring(p)])

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = tonumber(each.value)
  port_range_max    = tonumber(each.value)
  remote_ip_prefix  = var.remote_cidr

  security_group_id = openstack_networking_secgroup_v2.sg.id
}

# Verbesserungsidee:
# Egress-Regeln (ausgehend) explizit definieren, statt OpenStack-Defaults zu nutzen.