# Variables
variable "aws-launch-template-name" {}

variable "aws-launch-template-description" {}

variable ebs-volume-size {
  default = "8"
}

variable "instance-profile-arn" {}

variable "ec2-ami-id" {}

variable "ec2-instance-type" {}

variable "security-group-ids" {}

variable "ec2-user-data" {}

variable "ec2-tag" {}