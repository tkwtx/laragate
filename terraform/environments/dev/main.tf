module "vpc" {
  source = "../../modules/vpc"

  app_name          = var.app_name
  region            = var.aws_base_config.region
  vpc_cidr_block    = var.vpc_cidr_block
  subnet_cidr_block = var.subnet_cidr_block
  sg_conf           = var.sg_conf
}

module "acm" {
  source = "../../modules/acm"

  domain_name = var.domain_name
  env         = var.env

  alb_map = module.alb.alb_map
}

module "alb" {
  source = "../../modules/alb"

  app_name  = var.app_name

  acm     = module.acm.acm_main
  subnet  = module.vpc.subnet_public
  sg      = module.vpc.sg_alb
  s3      = module.s3.s3_lb
  vpc_id  = module.vpc.vpc_id
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  app_name  = var.app_name
  env       = var.env
}

module "ecs" {
  source = "../../modules/ecs"

  app_name  = var.app_name
  base_conf = var.aws_base_config
  env       = var.env

  tg      = module.alb.tg_ecs
  sg      = module.vpc.sg_alb
  subnets = module.vpc.subnet_private
  ecs_task_role = module.iam.ecs_task_role
  ecs_task_execution_role = module.iam.ecs_task_execution_role
}

module "iam" {
  source = "../../modules/iam"

  app_name  = var.app_name
  base_conf = var.aws_base_config
}

module "s3" {
  source = "../../modules/s3"

  app_name = var.app_name
}
