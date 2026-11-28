variable "environment" {
  type = string
}

variable "available_locations" {
  type = map(string)
}

variable "pub_keys" {
  type = map(string)
}

variable "ip_range" {
  type = string
}


variable "proxy_nodes" {
  type = map(object({
    server_type  = string
    location     = string
    image        = string
    ipv4_enabled = optional(bool, false)
    ipv6_enabled = optional(bool, false)
    private_ipv4 = string
    labels       = map(string)
  }))
}

variable "swarm_manager_nodes" {
  type = map(object({
    server_type  = string
    location     = string
    image        = string
    ipv4_enabled = optional(bool, false)
    ipv6_enabled = optional(bool, false)
    private_ipv4 = string
    labels       = map(string)
  }))
}

variable "vpn_node" {
  type = object({
    server_type  = string
    location     = string
    image        = string
    ipv4_enabled = optional(bool, true)
    ipv6_enabled = optional(bool, false)
    private_ipv4 = string
    labels       = map(string)
  })
}

variable "odoo_nodes" {
  type = map(object({
    server_type  = string
    location     = string
    image        = string
    ipv4_enabled = optional(bool, false)
    ipv6_enabled = optional(bool, false)
    private_ipv4 = string
    labels       = map(string)
  }))
}

variable "odoo_tenants" {
  description = "Odoo tenants keyed by project name"
  type = map(object({
    node       = string
    version    = string
    workers    = number
    max_memory = string
    max_cpus   = number
    repos      = map(string)
  }))

  validation {
    condition     = alltrue([for tenant in values(var.odoo_tenants) : can(var.odoo_nodes[tenant.node])])
    error_message = "Each Odoo tenant must reference an existing key in odoo_nodes."
  }
}
