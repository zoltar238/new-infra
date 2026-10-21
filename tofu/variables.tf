variable "available_locations" {
  type = map(string)
}

variable "pub_keys" {
  type = map(string)
}

variable "servers" {
  type = map(object({
    server_type  = string
    location     = string
    image        = string
    ipv4_enabled = optional(bool, true)
    ipv6_enabled = optional(bool, false)
    labels       = map(string)
  }))
}

