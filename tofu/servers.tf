resource "hcloud_primary_ip" "odoo_primary_ips" {
  for_each = {
    for k, v in var.odoo_nodes : k => v
    if v.ipv4_enabled
  }

  name        = "${each.key}-primary-ip"
  type        = "ipv4"
  location    = each.value.location
  auto_delete = false
  labels      = each.value.labels
}

resource "hcloud_primary_ip" "vpn_primary_ip" {
  name        = "$vpn-primary-ip"
  type        = "ipv4"
  location    = var.vpn_node.location
  auto_delete = false
  labels      = var.vpn_node.labels
}

resource "hcloud_server" "vpn_node" {
  name        = "vpn"
  image       = var.vpn_node.image
  server_type = var.vpn_node.server_type
  location    = var.vpn_node.location
  labels      = var.vpn_node.labels

  delete_protection  = true
  rebuild_protection = true
  // firewall_ids       = [hcloud_firewall.firewall.id]

  ssh_keys = values(hcloud_ssh_key.main)[*].id

  public_net {
    ipv4_enabled = var.vpn_node.ipv4_enabled
    ipv4         = hcloud_primary_ip.vpn_primary_ip.id
    ipv6_enabled = var.vpn_node.ipv6_enabled
  }

  network {
    subnet_id = hcloud_network_subnet.odoo_priv_subnet.id
    ip        = cidrhost(hcloud_network_subnet.odoo_priv_subnet.ip_range, 10)
  }

  lifecycle {
    ignore_changes = [
      labels,
      ssh_keys
    ]
  }
}

resource "hcloud_server" "odoo_nodes" {
  for_each    = var.odoo_nodes
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
    ipv4         = each.value.ipv4_enabled ? hcloud_primary_ip.odoo_primary_ips[each.key].id : null
    ipv6_enabled = each.value.ipv6_enabled
  }

  network {
    subnet_id = hcloud_network_subnet.odoo_priv_subnet.id
    ip        = cidrhost(hcloud_network_subnet.odoo_priv_subnet.ip_range, index(keys(var.odoo_nodes), each.key) + 20)
  }

  lifecycle {
    ignore_changes = [
      labels,
      ssh_keys
    ]
  }
}
