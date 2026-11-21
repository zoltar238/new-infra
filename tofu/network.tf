resource "hcloud_network" "odoo_priv_net" {
  name              = "odoo_priv_net"
  ip_range          = var.ip_range
  delete_protection = true
}

resource "hcloud_network_subnet" "odoo_priv_subnet" {
  type         = "cloud"
  network_id   = hcloud_network.odoo_priv_net.id
  network_zone = "eu-central"
  ip_range     = var.ip_range
}

# Private-only servers use the VPN server as their Internet NAT gateway.
resource "hcloud_network_route" "private_internet" {
  network_id  = hcloud_network.odoo_priv_net.id
  destination = "0.0.0.0/0"
  gateway     = var.vpn_node.private_ipv4

  depends_on = [hcloud_server.vpn_node]
}
