resource "aws_sqs_queue" "inventory_dlq" {

  name = "${var.project_name}-${var.environment}-inventory-dlq"

}

resource "aws_sqs_queue" "notification_dlq" {

  name = "${var.project_name}-${var.environment}-notification-dlq"

}

resource "aws_sqs_queue" "inventory" {

  name = "${var.project_name}-${var.environment}-inventory"

  visibility_timeout_seconds = 60

  message_retention_seconds = 345600

  redrive_policy = jsonencode({

    deadLetterTargetArn = aws_sqs_queue.inventory_dlq.arn

    maxReceiveCount = 5

  })

}

resource "aws_sqs_queue" "notification" {

  name = "${var.project_name}-${var.environment}-notification"

  visibility_timeout_seconds = 60

  message_retention_seconds = 345600

  redrive_policy = jsonencode({

    deadLetterTargetArn = aws_sqs_queue.notification_dlq.arn

    maxReceiveCount = 5

  })

}

data "aws_iam_policy_document" "inventory_queue_policy" {

  statement {

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      aws_sqs_queue.inventory.arn
    ]

    condition {

      test = "ArnEquals"

      variable = "aws:SourceArn"

      values = [
        var.sns_topic_arn
      ]
    }
  }
}


resource "aws_sqs_queue_policy" "inventory" {

  queue_url = aws_sqs_queue.inventory.id

  policy = data.aws_iam_policy_document.inventory_queue_policy.json

}

data "aws_iam_policy_document" "notification_queue_policy" {

  statement {

    effect = "Allow"

    principals {
      type = "Service"

      identifiers = ["sns.amazonaws.com"]
    }

    actions = [

      "sqs:SendMessage"

    ]

    resources = [

      aws_sqs_queue.notification.arn

    ]

    condition {

      test = "ArnEquals"

      variable = "aws:SourceArn"

      values = [

        var.sns_topic_arn

      ]
    }

  }

}


resource "aws_sqs_queue_policy" "notification" {

  queue_url = aws_sqs_queue.notification.id

  policy = data.aws_iam_policy_document.notification_queue_policy.json

}

resource "aws_sns_topic_subscription" "inventory" {

  topic_arn = var.sns_topic_arn

  protocol = "sqs"

  endpoint = aws_sqs_queue.inventory.arn

}

resource "aws_sns_topic_subscription" "notification" {

  topic_arn = var.sns_topic_arn

  protocol = "sqs"

  endpoint = aws_sqs_queue.notification.arn

}