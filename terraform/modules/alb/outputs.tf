output "alb_map" {
  value = aws_lb.main
}

output "tg_ecs" {
  value = aws_lb_target_group.ip_target_group
}