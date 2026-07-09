output "environment" {
  value = var.environment
}


output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "order_service_url" {
  value = "http://${module.alb.alb_dns_name}"
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}

output "sns_topic_arn" {
  value = module.sns.topic_arn
}

output "inventory_queue_url" {
  value = module.sqs.inventory_queue_url
}

output "notification_queue_url" {
  value = module.sqs.notification_queue_url
}

output "cluster_name" {
  value = module.ecs.cluster_name
}

output "repository_urls" {
  value = module.ecr.repository_urls
}