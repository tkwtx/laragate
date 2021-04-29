output "s3_lb" {
  value = aws_s3_bucket.alb_log
}

output "s3_ecs" {
  value = aws_s3_bucket.ecs_log
}