resource "hcloud_ssh_key" "main" {
  for_each   = var.pub_keys
  name       = each.key
  public_key = each.value
}
