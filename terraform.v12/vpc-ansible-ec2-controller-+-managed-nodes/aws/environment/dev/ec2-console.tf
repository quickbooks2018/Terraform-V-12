resource "aws_iam_instance_profile" "aws-iam-instance-profile" {
  name = "aws-iam-instance-profile"
  role = aws_iam_role.ec2-role.name
}

resource "aws_iam_role" "ec2-role" {
  name = "ec2-rabbitmq-cluster-role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}


# EC2 Console Access attaching existing policy
# https://gist.github.com/pubudusj/053f8846f6ca94a72e87757a79455640
data "aws_iam_policy" "ssm-ec2-console-policy" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "ssm-ec2-console-policy-for-ec2-role" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = data.aws_iam_policy.ssm-ec2-console-policy.arn
}
