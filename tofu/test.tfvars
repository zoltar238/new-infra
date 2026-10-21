available_locations = {
  "de_falkenstein"  = "fsn1"
  "de_nuremberg"    = "nbg1"
  "fi_helsinki"     = "hel1"
  "us_ashburn_va"   = "ash"
  "us_hillsboro_or" = "hil"
  "sg_singapore"    = "sin"
}

pub_keys = { andrei = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMxd4Er7oE3oRM6ZVvi4OwbylRHqRL7K+N/fGQ2E4mX/ andrei@andrei-pc" }

vpn_node = {
  server_type  = "cx23"
  location     = "nbg1"
  image        = "ubuntu-26.04"
  ipv4_enabled = true
  ipv6_enabled = false
  labels = {
    "test" = "test1",
    "vpn"  = "vpn"
  }
}

odoo_nodes = {
  "odoo1" = {
    server_type  = "cax11"
    location     = "nbg1"
    image        = "ubuntu-26.04"
    ipv4_enabled = false
    ipv6_enabled = false
    labels = {
      "test" = "test1",
      "odoo" = "odoo"
    }
  }
  "odoo2" = {
    server_type  = "cax11"
    location     = "nbg1"
    image        = "ubuntu-26.04"
    ipv4_enabled = false
    ipv6_enabled = false
    labels = {
      "test" = "test1",
      "odoo" = "odoo"
    }
  }
}
