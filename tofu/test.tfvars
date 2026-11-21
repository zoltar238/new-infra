environment = "prod"

available_locations = {
  "de_falkenstein"  = "fsn1"
  "de_nuremberg"    = "nbg1"
  "fi_helsinki"     = "hel1"
  "us_ashburn_va"   = "ash"
  "us_hillsboro_or" = "hil"
  "sg_singapore"    = "sin"
}

pub_keys = {
  ansible = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP55HD5nSkE/mLcn3Xt0Jnbc0ac00mzVtxtAw6phCYXb"
  andrei  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ70nKbc3KOv7ooSo8AZLVpWSuid2e8qlKhKjdoDX+hm"
}

ip_range = "10.0.1.0/24"

vpn_node = {
  server_type  = "cx23"
  location     = "nbg1"
  image        = "ubuntu-26.04"
  ipv4_enabled = true
  ipv6_enabled = false
  private_ipv4 = "10.0.1.10"
  labels = {
    "test" = "test1",
    "vpn"  = "vpn"
  }
}

odoo_nodes = {
  "odoo1" = {
    server_type  = "cx23"
    location     = "nbg1"
    image        = "ubuntu-26.04"
    ipv4_enabled = false
    ipv6_enabled = false
    private_ipv4 = "10.0.1.30"
    labels = {
      "test" = "test1",
      "odoo" = "odoo"
    }
  }
  "odoo2" = {
    server_type  = "cx23"
    location     = "nbg1"
    image        = "ubuntu-26.04"
    ipv4_enabled = false
    ipv6_enabled = false
    private_ipv4 = "10.0.1.31"
    labels = {
      "test" = "test1",
      "odoo" = "odoo"
    }
  }
}

proxy_nodes = {
  "proxy1" = {
    server_type  = "cpx12"
    location     = "nbg1"
    image        = "ubuntu-26.04"
    ipv4_enabled = false
    ipv6_enabled = false
    private_ipv4 = "10.0.1.40"
    labels = {
      "swarm" = "worker"
      role    = "proxy"
    }
  }
}

swarm_manager_nodes = {
  "manager1" = {
    server_type  = "cpx12"
    location     = "nbg1"
    image        = "ubuntu-26.04"
    ipv4_enabled = false
    ipv6_enabled = false
    private_ipv4 = "10.0.1.20"
    labels = {
      "test"    = "test",
      "manager" = "manager"
    }
  }
}
