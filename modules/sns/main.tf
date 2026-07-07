resource "aws_sns_topic" "order_events" {

  name = "${var.project_name}-${var.environment}-order-events"

  tags = {

    Name = "${var.project_name}-${var.environment}-order-events"
  }

}