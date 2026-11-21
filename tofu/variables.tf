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

