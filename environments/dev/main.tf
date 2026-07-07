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