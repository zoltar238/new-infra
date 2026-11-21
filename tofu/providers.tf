terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.70"
    }
    bitwarden-secrets = {
      source  = "bitwarden/bitwarden-secrets"
      version = "1.0.1"
    }
  }
}

provider "bitwarden-secrets" {
  identity_url    = "https://identity.bitwarden.eu"
  api_url         = "https://api.bitwarden.eu"
  organization_id = "852485cd-37ef-4a1d-97c7-b4fa00b61dd7"
}

provider "hcloud" {
  poll_interval = "1000ms"
  token         = data.bitwarden-secrets_secret.hetzner_token.value
}

