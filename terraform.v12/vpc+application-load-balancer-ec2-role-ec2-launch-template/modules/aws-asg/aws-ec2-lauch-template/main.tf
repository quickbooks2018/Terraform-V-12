resource "aws_launch_template" "aws-launch-template" {
  name = var.aws-launch-template-name
  description = var.aws-launch-template-description

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = var.ebs-volume-size
    }
  }

  credit_specification {
    cpu_credits = "standard"
  }

  disable_api_termination = false

  ebs_optimized = true

  iam_instance_profile {
    arn = var.instance-profile-arn
  }

  image_id = var.ec2-ami-id

  instance_initiated_shutdown_behavior = "stop"

  instance_type = var.ec2-instance-type

  key_name = "rabbitmq"

  monitoring {
    enabled = false
  }

  network_interfaces {
    associate_public_ip_address = false
  }

  vpc_security_group_ids = var.security-group-ids

  user_data = var.ec2-user-data


  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = var.ec2-tag
      service = var.ec2-tag
    }
  }
}
