resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"
}

resource "aws_ecs_service" "main" {
  name                    = "${var.app_name}-service"
  cluster                 = aws_ecs_cluster.main.arn
  task_definition         = aws_ecs_task_definition.service.arn
  desired_count           = 2
  enable_execute_command  = true
  launch_type             = "FARGATE"

  load_balancer {
    target_group_arn  = var.tg.arn
    container_name    = "nginx"
    container_port    = 80
  }

  network_configuration {
    subnets           = var.subnets
    security_groups   = [var.sg.id]
    assign_public_ip  = true
  }
}

resource "aws_ecs_task_definition" "service" {
  family                    = "${var.app_name}-service"
  network_mode              = "awsvpc"
  execution_role_arn        = var.ecs_task_execution_role.arn
  task_role_arn             = var.ecs_task_role.arn
  requires_compatibilities  = ["FARGATE"]
  cpu                       = 256
  memory                    = 512

  container_definitions = jsonencode([
    {
      name = "nginx"
      image = "${var.base_conf.account_id}.dkr.ecr.${var.base_conf.region}.amazonaws.com/${var.app_name}/nginx"
      linuxParameters = {
        initProcessEnabled = true
      }
      portMappings = [
        {
          containerPort = 80
          hostPort = 80
          protocol = "tcp"
        }
      ]
      essential = true,
      dependsOn = [
        {
          containerName = "laravel"
          condition = "START"
        }
      ]
      readonlyRootFilesystem = false
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "/ecs/${var.app_name}"
          awslogs-region = var.base_conf.region
          awslogs-stream-prefix = "nginx"
        }
      }
    },
    {
      name = "laravel"
      image =  "${var.base_conf.account_id}.dkr.ecr.${var.base_conf.region}.amazonaws.com/${var.app_name}/laravel"
      linuxParameters = {
        initProcessEnabled = true
      }
      essential = false
      environment = [
        {
          name = "APP_ENV"
          value = var.env
        },
        {
          name = "APP_DEBUG"
          value = "false"
        },
        {
          name = "LOG_CHANNEL"
          value = "stderr"
        }
      ]
      secrets = [
//        {
//          name = "DB_HOST",
//          valueFrom = "arn:aws:ssm:${var.base_conf.region}:${var.base_conf.account_id}:parameter/DB_HOST"
//        },
//        {
//          name = "DB_PASSWORD",
//          valueFrom = "arn:aws:ssm:${var.base_conf.region}:${var.base_conf.account_id}:parameter/DB_PASSWORD"
//        },
        {
          name = "APP_KEY",
          valueFrom = "arn:aws:ssm:${var.base_conf.region}:${var.base_conf.account_id}:parameter/APP_KEY"
        }
      ]
      privileged = false
      readonlyRootFilesystem = false
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "/ecs/${var.app_name}"
          awslogs-region = var.base_conf.region
          awslogs-stream-prefix = "laravel"
        }
      }
    }
  ])

}