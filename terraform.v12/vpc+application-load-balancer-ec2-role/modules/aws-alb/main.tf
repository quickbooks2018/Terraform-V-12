resource "aws_lb" "alb" {
  name               = var.alb-name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [var.alb-sg]
  subnets            = var.alb-subnets

  enable_deletion_protection = "true"


  tags = {
    Name = var.alb-tag
  }
}

resource "aws_alb_listener" "frontend-listner-80" {
  default_action {
    target_group_arn = var.target-group-arn
    type = "forward"
  }
  load_balancer_arn = aws_lb.alb.arn
  port = 80
}

resource "aws_alb_listener" "frontend-listner-8080" {
  default_action {
    target_group_arn = var.target-group-arn
    type = "forward"
  }
  load_balancer_arn = aws_lb.alb.arn
  port = 8080
}


resource "aws_alb_listener" "frontend-listner-443" {
  default_action {
    target_group_arn = var.target-group-arn
    type = "forward"
  }
  load_balancer_arn = aws_lb.alb.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.certificate-arn
}
