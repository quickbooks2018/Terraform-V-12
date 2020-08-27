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


#RDS VARIABLES

variable "rds-name" {
  default = ""
}

variable "final-snapshot-identifier" {
  default = ""
}

variable "rds-allocated-storage" {
  default = ""
}

variable "storage-type" {
  default = ""
}

variable "rds-engine" {
  default = ""
}

variable "engine-version" {
  default = ""
}

variable "db-instance-class" {
  default = ""
}

#These are automated backups
variable "backup-retension-period" {
  default = ""
}

variable "backup-window" {
  default = ""
}

variable "publicly-accessible" {
  default = ""
}

variable "rds-username" {
  default = ""
}

variable "rds-password" {
  default = ""
}

variable "skip-final-snapshot" {
  default = ""
}

variable "multi-az" {
  default = ""
}




#NOTE: PLEASE ONLY PUT THE PRIVATE-SUBNET IDS
variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "A list of VPC Subnet IDs to launch in"
  type        = list(string)
  default     = []
}


variable "vpc-security-group-ids" {
  default = ""
}

variable "storage-encrypted" {
  default = ""
}

variable "deletion-protection" {
  default = ""
}



