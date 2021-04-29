locals {
  target_task_execution_role_policy = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  ]
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.app_name}EcsTaskExecutionRole"
  assume_role_policy = file("files/assume_role_policy/ecs-tasks-trust-policy.json")
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.app_name}EcsTaskRole"
  assume_role_policy = file("files/assume_role_policy/ecs-tasks-trust-policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attach" {
  for_each = toset(local.target_task_execution_role_policy)

  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "ecs_exec" {
  name    = "ecs-exec-task-role-policy"
  role    = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        Resource: "*"
      },
      {
        Effect: "Allow",
        Action: [
          "logs:DescribeLogGroups"
        ],
        Resource: "*"
      },
      {
        Effect: "Allow",
        Action: [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ],
        Resource: "arn:aws:logs:${var.base_conf.region}:${var.base_conf.account_id}:log-group:/ecs/${var.app_name}:*"
      },
      {
        Effect: "Allow",
        Action: [
          "s3:PutObject"
        ],
        Resource: "arn:aws:s3:::ecs-logs-${var.app_name}/*"
      },
      {
        Effect: "Allow",
        Action: [
          "s3:GetEncryptionConfiguration"
        ],
        Resource: "arn:aws:s3:::ecs-logs-${var.app_name}"
      },
      {
        Effect: "Allow",
        Action: [
          "kms:Decrypt"
        ],
        Resource: aws_kms_key.this.arn
      }
    ]
  })
}

resource "aws_kms_key" "this" {}
