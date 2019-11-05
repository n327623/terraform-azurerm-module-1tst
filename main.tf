data "azurerm_resource_group" "sta_rg" {
  name = var.resource_group
}

locals {
  location = var.location == null ? data.azurerm_resource_group.sta_rg.location : var.location
  
}

resource "azurerm_storage_account" "sta" {
  name                     = var.name
  resource_group_name      = data.azurerm_resource_group.sta_rg.name
  location                 = local.location
  account_tier             = var.storage_tier
  account_replication_type = var.storage_replication
  tags = {
    cost_center     = data.azurerm_resource_group.sta_rg.tags["cost_center"]
    product         = data.azurerm_resource_group.sta_rg.tags["product"]
    channel         = var.channel
    description     = var.description
    tracking_code   = var.tracking_code
    cia             = var.cia
  }
}

