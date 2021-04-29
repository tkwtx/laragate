resource "aws_lb" "main" {
  name                = "alb-${var.app_name}"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = [var.sg.id]
  subnets             = var.subnet

  enable_deletion_protection = false

  access_logs {
    bucket  = var.s3.bucket
    prefix  = var.app_name
    enabled = true
  }
}

resource "aws_lb_target_group" "ip_target_group" {
  name        = "lb-tg-${var.app_name}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}


resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.acm.arn

  default_action {
    target_group_arn  = aws_lb_target_group.ip_target_group.arn
    type              = "forward"
  }
}

resource "aws_lb_listener" "redirect" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
