output "emr_service_role" {
  value = aws_iam_role.emr_service_role.arn
}

output "emr_autoscaling_role" {
  value = aws_iam_role.emr_autoscaling_role.arn
}

output "emr_ec2_instance_profile" {
  value = aws_iam_instance_profile.emr_ec2_instance_profile.arn
}
