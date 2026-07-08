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