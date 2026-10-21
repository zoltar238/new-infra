variable "available_locations" {
  type = map(string)
}

variable "pub_keys" {
  type = map(string)
}

variable "odoo_nodes" {
  type = map(object({
    server_type  = string
    location     = string
    image        = string
    ipv4_enabled = optional(bool, false)
    ipv6_enabled = optional(bool, false)
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
    labels       = map(string)
  })
}

