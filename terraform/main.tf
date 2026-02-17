terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}

# OpenStack-Zugangsdaten als Variablen
provider "openstack" {
  auth_url    = var.auth_url
  tenant_name = var.project
  user_name   = var.user
  password    = var.password
  region      = var.region

  # Für Produktion besser: korrektes CA-Zertifikat konfigurieren
  insecure    = true
}

module "network" {
  source          = "./modules/network"
  network_name    = var.network_name
  subnet_cidr     = var.subnet_cidr
  dns_nameservers = var.dns_nameservers

  providers = { openstack = openstack }
}

# Interner Security Group: nur SSH aus dem privaten Subnetz.
# Verbesserungsidee: SSH weiter einschränken (z.B. nur Jump-Host-IP statt ganzes Subnetz).
module "security_k8s_internal" {
  source        = "./modules/security"
  sg_name       = "k8s-internal-sg"
  allowed_ports = [22]              # intern SSH (für Jump + Admin)
  remote_cidr   = var.subnet_cidr   # nur aus dem privaten Subnetz
  providers = { openstack = openstack }
}

module "security_controlplane_public" {
  source        = "./modules/security"
  sg_name       = "k8s-controlplane-public-sg"
  allowed_ports = [22, 80, 443, 3000, 6443]  # SSH + HTTP/S + Grafana + Kubernetes API 
  remote_cidr   = var.uni_vpn_cidr
  providers = { openstack = openstack }
}

# Zusätzliche Regel: erlaubt allen Ingress-Traffic innerhalb des privaten Netzes.
# vereinfacht Cluster-internen Verkehr, ist aber relativ permissiv.
# Verbesserungsidee: nur benötigte Protokolle/Ports freigeben oder separate SGs
# für Node-to-Node und Service-Traffic verwenden.
resource "openstack_networking_secgroup_rule_v2" "k8s_internal_allow_all_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = null              # null = any protocol
  remote_ip_prefix  = var.subnet_cidr
  security_group_id = module.security_k8s_internal.sg_id
}

# Control-Plane. Hier 1 Instanz.
module "control_plane" {
  source = "./modules/compute"

  instance_count      = 1
  name_prefix         = "k8s-control"
  image_id            = var.image_id
  flavor              = var.server_flavor
  volume_size         = var.server_volume_size
  network_id = module.network.network_id
  subnet_id  = module.network.subnet_id
  keypair_name = openstack_compute_keypair_v2.k8s.name
  security_group_ids  = [
    module.security_k8s_internal.sg_id,
    module.security_controlplane_public.sg_id
  ]
}

# Worker Nodes (hier 3 Instanzen). Nur intern erreichbar.
module "workers" {
  source = "./modules/compute"

  instance_count      = 3
  name_prefix         = "k8s-worker"
  image_id            = var.image_id
  flavor              = var.worker_flavor
  volume_size         = var.worker_volume_size
  network_id = module.network.network_id
  subnet_id  = module.network.subnet_id
  keypair_name = openstack_compute_keypair_v2.k8s.name
  security_group_ids  = [module.security_k8s_internal.sg_id]
}

# Verbindet das private Subnetz mit dem bestehenden Router.
resource "openstack_networking_router_interface_v2" "router_if" {
  router_id = var.existing_router_id
  subnet_id = module.network.subnet_id
}

data "openstack_networking_network_v2" "external" {
  name = var.external_network_name
}

resource "openstack_networking_floatingip_v2" "control_fip" {
  pool = data.openstack_networking_network_v2.external.name
}

# Verknüpft Floating IP mit dem Port der ersten Control-Plane-Instanz.
# Hinweis: bei >1 Control-Plane Nodes bräuchte man entweder Load Balancer
# oder mehrere Floating IPs.
resource "openstack_networking_floatingip_associate_v2" "control_fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.control_fip.address
  port_id     = module.control_plane.port_ids[0]

  depends_on = [openstack_networking_router_interface_v2.router_if]
}

# Importiert den lokalen Public Key als OpenStack Keypair für SSH-Zugriff.
resource "openstack_compute_keypair_v2" "k8s" {
  name       = "uni-k8s-key"
  public_key = file(var.ssh_public_key_path)
}



