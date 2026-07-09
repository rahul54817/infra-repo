module "vpc" {

  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment
}

module "security_group" {

  source = "../../modules/security-group"

  project_name = var.project_name
  environment  = var.environment

  vpc_id = module.vpc.vpc_id
}

module "ecr" {

  source = "../../modules/ecr"

  project_name = var.project_name

  environment = var.environment

  repositories = var.repositories
}

module "rds" {

  source = "../../modules/rds"

  project_name = var.project_name

  environment = var.environment

  private_subnet_ids = module.vpc.private_subnet_ids

  rds_security_group_id = module.security_group.rds_security_group_id
}

module "sns" {

  source = "../../modules/sns"

  project_name = var.project_name

  environment = var.environment

}


module "sqs" {

  source = "../../modules/sqs"

  project_name = var.project_name

  environment = var.environment

  sns_topic_arn = module.sns.topic_arn

}

module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
  environment  = var.environment

  sns_topic_arn          = module.sns.topic_arn
  inventory_queue_arn    = module.sqs.inventory_queue_arn
  notification_queue_arn = module.sqs.notification_queue_arn
}

module "ecs" {

  source = "../../modules/ecs"

  project_name = var.project_name

  environment = var.environment

}


module "alb" {

  source = "../../modules/alb"

  project_name = var.project_name
  environment  = var.environment

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_group.alb_security_group_id
}

module "order_service" {

  source = "../../modules/ecs-service"

  project_name = var.project_name
  environment  = var.environment

  service_name = "order-service"

  cluster_id = module.ecs.cluster_id

  execution_role_arn = module.iam.ecs_execution_role_arn
  task_role_arn      = module.iam.order_task_role_arn

  container_image = "${module.ecr.repository_urls["order-service"]}:latest"

  container_port = 8080

  cpu    = 256
  memory = 512

  desired_count = 1

  subnet_ids = module.vpc.private_subnet_ids

  security_group_ids = [
    module.security_group.ecs_security_group_id
  ]

  assign_public_ip = false

  target_group_arn = module.alb.order_target_group_arn

  aws_region = "ap-south-1"

  environment_variables = [

    {
      name  = "APP_ENV"
      value = "dev"
    },

    {
      name  = "APP_PORT"
      value = "8080"
    },

    {
      name  = "DB_HOST"
      value = split(":", module.rds.db_endpoint)[0]
    },

    {
      name  = "DB_PORT"
      value = "5432"
    },

    {
      name  = "DB_NAME"
      value = "order_management"
    },

    {
      name  = "DB_USER"
      value = "dbadmin"
    },

    {
      name  = "DB_PASSWORD"
      value = "postgres"
    },

    {
      name  = "AWS_REGION"
      value = var.aws_region
    },

    {
      name  = "SNS_TOPIC_ARN"
      value = module.sns.topic_arn
    }

  ]

}