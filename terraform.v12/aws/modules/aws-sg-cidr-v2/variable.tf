variable "namespace" {
  type        = string
  description = "Namespace (e.g. `eg` or `cp`)"
  default     = ""
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  default     = ""
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `name`, `namespace`, `stage` and `attributes`"
}

variable "enabled" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}


variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
  default = {}
}


variable "security_group_name"{
  type        = string
  description = "Name to be used on all the resources as identifier"
}

variable "vpcID" {
  type        = string
  description = "The ID of the VPC"
  default     = ""
}

# Enable ports

variable "ServicePorts" {
  type = map(number)
  default = {
    vaultServerPort  = 8200
    vaultClusterAddr = 8201
    serverRpcPort    = 8300
    serfLanPort      = 8301
    serfWanPort      = 8302
    cliRpcPort       = 8400
    httpApiPort      = 8500
    httpsApiPort     = 8501
    dnsPort          = 8600
    http             = 80
    https            = 443
  }
}

variable "cidr" {
  type  = string
  description = "VPC CIDR to allow"
  default = ""
}

variable "peerCIDR" {
  type  = string
  description = "VPC peering CIDR to allow"
  default = "172.30.0.0/16"
}