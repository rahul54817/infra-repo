output "topic_arn" {

  value = aws_sns_topic.order_events.arn

}

output "topic_name" {

  value = aws_sns_topic.order_events.name

}