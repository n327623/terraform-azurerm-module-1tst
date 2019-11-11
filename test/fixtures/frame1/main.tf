terraform {
  required_version = ">= 0.12"
}

provider "azurerm" {
  version = ">=1.34.0"
}

module "sta" {
  source = "../../../"

  name   = var.name
  resource_group  = var.resource_group

  location          = var.location
  storage_tier       = var.storage_tier
  storage_replication           = var.storage_replication

  channel       = var.channel
  description           = var.description
  cia   = var.cia
  tracking_code = var.tracking_code
}
