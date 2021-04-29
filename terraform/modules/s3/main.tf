resource "aws_s3_bucket" "tfstate_storage" {
  bucket  = "tfstate-${var.app_name}"
  acl     = "private"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "ecs_log" {
  bucket = "ecs-logs-${var.app_name}"
  acl    = "private"
  force_destroy = true
}

resource "aws_s3_bucket" "alb_log" {
  bucket = "lb-logs-${var.app_name}"
  acl    = "private"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}
