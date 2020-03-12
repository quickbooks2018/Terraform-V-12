variable "name" {}
variable "region" {}
variable "subnet_id" {}
variable "vpc_id" {}
variable "key_name" {}
variable "release_label" {}
variable "applications" {
  type = "list"
}
variable "master_instance_type" {}
variable "master_ebs_size" {}
variable "core_instance_type" {}
variable "core_instance_count" {}
variable "core_ebs_size" {}
variable "ingress_cidr_blocks" {}
