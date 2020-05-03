# aws_ec2_client_vpn_endpoint
variable "Client_Vpn_Name" {}

variable "description" {}

variable "server_certificate_arn" {}

variable "client_cidr_block" {}

variable "split_tunnel" {}


# authentication_options
variable "type" {}

variable "root_certificate_chain_arn" {}

variable "active_directory_id" {}


# connection_log_options

variable "enabled" {}

variable "cloudwatch_log_group_name" {}

variable "cloudwatch_log_stream_name" {}

