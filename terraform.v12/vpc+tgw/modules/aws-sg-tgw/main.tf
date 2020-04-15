
resource "aws_security_group" "security_group" {
  name = var.security_group_name
  vpc_id = var.vpc_id

  # Rule-1
  ingress {
    from_port          = var.ingress-rule-1-from-port
    to_port            = var.ingress-rule-1-to-port
    protocol           = var.ingress-rule-1-protocol
    cidr_blocks        = var.ingress-rule-1-cidrs
    description        = var.ingress-rule-1-description
  }

//  # Rule-2
//  ingress {
//    from_port          = var.ingress-rule-2-from-port
//    to_port            = var.ingress-rule-2-to-port
//    protocol           = var.ingress-rule-2-protocol
//    security_groups    = var.ingress-rule-2-security-groups
//    description        = var.ingress-rule-2-description
//  }
//
  # Rule-3
  ingress {
    from_port          = var.ingress-rule-3-from-port
    to_port            = var.ingress-rule-3-to-port
    protocol           = var.ingress-rule-3-protocol
    cidr_blocks        = var.ingress-rule-3-cidrs
    description        = var.ingress-rule-3-description
  }

//
//  # Rule-4
//  ingress {
//    from_port          = var.ingress-rule-4-from-port
//    to_port            = var.ingress-rule-4-to-port
//    protocol           = var.ingress-rule-4-protocol
//    cidr_blocks        = var.ingress-rule-4-cidrs
//    description        = var.ingress-rule-4-description
//  }
//
//  # Rule-5
//  ingress {
//    from_port          = var.ingress-rule-5-from-port
//    to_port            = var.ingress-rule-5-to-port
//    protocol           = var.ingress-rule-5-protocol
//    security_groups    = var.ingress-rule-5-security-groups
//    description        = var.ingress-rule-5-description
//  }

//  # Rule-6
//  ingress {
//    from_port          = var.ingress-rule-6-from-port
//    to_port            = var.ingress-rule-6-to-port
//    protocol           = var.ingress-rule-6-protocol
//    security_groups    = var.ingress-rule-6-security-groups
//    description        = var.ingress-rule-6-description
//  }





  # Rule-Egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }

}