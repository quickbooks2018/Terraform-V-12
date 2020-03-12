#IAM ROLE CREATION

#########
# Labels
########
module "label" {
  source     = "../terraform-label"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
  enabled    = var.enabled
}



resource "aws_iam_role" "this" {

  name               = var.iam-role-name
  tags               = module.label.tags
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


resource "aws_iam_policy" "policy" {
  name = var.policy-name
  policy = var.policy
}

resource "aws_iam_role_policy_attachment" "policy-attach" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.policy.arn
}