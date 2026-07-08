    output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution.arn
}

output "order_task_role_arn" {
  value = aws_iam_role.order_service.arn
}

output "inventory_task_role_arn" {
  value = aws_iam_role.inventory_service.arn
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda.arn
}