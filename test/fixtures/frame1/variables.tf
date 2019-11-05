variable "name" {
    type        = string
    description = "(Required) VPn Gateway name. Do not forget to follow the naming conventions."
}

variable "resource_group" {
  type        = string
  description = "(Required) The name of the resource group in which the Gateway is created."
}


variable "location" {
  type        = string
  description = "(Optional) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  default     = null
}

variable "storage_tier" {
    type        = string
    description = "(Required) Defines the Tier to use for this storage account. Valid options are Standard and Premium. For FileStorage accounts only Premium is valid. Changing this forces a new resource to be created."
}

variable "storage_replication" {
    type= string
    description = "(Required) Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS and ZRS."
}

#TAGS
variable "channel" {
  type = string
  description = "(Optional) Distribution channel to which the associated resource belongs to."
  default     = ""
}


variable "description" {
  type = string
  description = "(Required) Provide additional context information describing the resource and its purpose."
}

variable "tracking_code" {
  type = string
  description = "(Optional) Allow this resource to be matched against internal inventory systems."
}

variable "cia" {
  type        = string
  description = "(Required) Confidentiality-Integrity-Availability"
  
}
