resource "hcloud_network" "odoo_priv_net" {
  name              = "odoo_priv_net"
  ip_range          = "10.0.1.0/24"
  delete_protection = true
}

resource "hcloud_network_subnet" "odoo_priv_subnet" {
  type         = "cloud"
  network_id   = hcloud_network.odoo_priv_net.id
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}
