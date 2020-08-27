variable "namespace" {
  type        = string
  default     = ""
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg'"
}

variable "stage" {
  type        = string
  default     = ""
  description = "Stage, e.g. 'prod', 'staging', 'dev'"
}

variable "name" {
  type        = string
  description = "Name of the secret to be stored"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources"
}

variable "convert_case" {
  type        = bool
  default     = true
  description = "Convert fields to lower case"
}

variable "managed" {
  type        = string
  default     = "Terraform"
  description = "Set managed by tag on resources"
}


variable "kms_key_id" {
  type        = string
  description = "KMS key id used for encrypting key at rest by aws secrets manager"
}

variable "version_stages" {
  type        = list(string)
  default     = ["AWSCURRENT"]
  description = " Specifies a list of staging labels that are attached to this version of the secret. A staging label must be unique to a single version of the secret"
}

variable "rotation_enabled" {
  default = "false"
}

variable "rotation_lambda_arn" {
  default = ""
}

variable "secret-string" {
  default = {
    username             = ""
    password             = ""
    engine               = ""
    host                 = ""
    port                 = ""
    dbInstanceIdentifier = ""
  }

  type = map(string)
}