resource "aws_cloudwatch_log_group" "ecs_cloudwatch" {
  name = "/ecs/${var.app_name}"
  retention_in_days = 30

  tags = {
    Environment = var.env
    Application = var.app_name
  }
}