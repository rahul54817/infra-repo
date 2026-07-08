output "inventory_queue_arn" {

  value = aws_sqs_queue.inventory.arn

}

output "notification_queue_arn" {

  value = aws_sqs_queue.notification.arn

}

output "inventory_queue_url" {

  value = aws_sqs_queue.inventory.id

}

output "notification_queue_url" {

  value = aws_sqs_queue.notification.id

}