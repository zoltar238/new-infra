resource "ansible_group" "swarm" {
  name     = "swarm"
  children = ["swarm_managers", "swarm_workers"]
  variables = {
    initial_user = "root"
    ansible_user = "ansible"
  }
}

resource "ansible_group" "swarm_workers" {
  name     = "swarm_workers"
  children = ["proxy", "odoo"]
}

resource "ansible_host" "vpn" {
  name   = "vpn1"
  groups = ["vpn"]
  variables = {
    ansible_host = hcloud_server.vpn_node.ipv4_address
    initial_user = "root"
    ansible_user = "ansible"
  }
}

resource "ansible_host" "swarm_managers" {
  for_each = var.swarm_manager_nodes

  name   = each.key
  groups = ["swarm_managers"]
  variables = {
    ansible_host = each.value.private_ipv4
  }
}

resource "ansible_host" "proxy_workers" {
  for_each = var.proxy_nodes

  name   = each.key
  groups = ["proxy"]
  variables = {
    ansible_host = each.value.private_ipv4
  }
}

resource "ansible_host" "odoo_workers" {
  for_each = var.odoo_nodes

  name   = each.key
  groups = ["odoo"]
  variables = {
    ansible_host = each.value.private_ipv4
    odoo_hosts = [
      for project_name, tenant in var.odoo_tenants : {
        project_name = project_name
        version      = tenant.version
        workers      = tenant.workers
        max_memory   = tenant.max_memory
        max_cpus     = tenant.max_cpus
        repos = [
          for name, url in tenant.repos : { name = name, url = url }
        ]
      } if tenant.node == each.key
    ]
  }
}
