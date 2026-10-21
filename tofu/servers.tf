resource "hcloud_primary_ip" "odoo_primary_ips" {
  for_each    = var.servers
  name        = "${each.key}-primary-ip"
  type        = "ipv4"
  location    = each.value.location
  auto_delete = false
  labels      = each.value.labels
}

resource "hcloud_server" "odoo_nodes" {
  for_each    = var.servers
  name        = each.key
  image       = each.value.image
  server_type = each.value.server_type
  location    = each.value.location
  labels      = each.value.labels

  delete_protection  = true
  rebuild_protection = true
  firewall_ids       = [hcloud_firewall.firewall.id]

  ssh_keys = values(hcloud_ssh_key.main)[*].id

  public_net {
    ipv4_enabled = each.value.ipv4_enabled
    ipv4         = hcloud_primary_ip.odoo_primary_ips[each.key].id
    ipv6_enabled = each.value.ipv6_enabled
  }

  network {
    subnet_id = hcloud_network_subnet.odoo_priv_subnet.id
    ip = cidrhost(hcloud_network_subnet.odoo_priv_subnet.ip_range, index(keys(var.servers), each.key) + 20 )
}

  lifecycle {
    ignore_changes = [
      labels,
      ssh_keys
    ]
  }
}
