data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ecs_execution" {
  name               = "${var.project_name}-${var.environment}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "order_service" {
  name               = "${var.project_name}-${var.environment}-order-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

data "aws_iam_policy_document" "order_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sns:Publish"
    ]

    resources = [
      var.sns_topic_arn
    ]
  }
}

resource "aws_iam_policy" "order" {
  name   = "${var.project_name}-${var.environment}-order-policy"
  policy = data.aws_iam_policy_document.order_policy.json
}

resource "aws_iam_role_policy_attachment" "order" {
  role       = aws_iam_role.order_service.name
  policy_arn = aws_iam_policy.order.arn
}

resource "aws_iam_role" "inventory_service" {
  name               = "${var.project_name}-${var.environment}-inventory-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

data "aws_iam_policy_document" "inventory_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ChangeMessageVisibility"
    ]

    resources = [
      var.inventory_queue_arn
    ]
  }
}

resource "aws_iam_policy" "inventory" {
  name   = "${var.project_name}-${var.environment}-inventory-policy"
  policy = data.aws_iam_policy_document.inventory_policy.json
}

resource "aws_iam_role_policy_attachment" "inventory" {
  role       = aws_iam_role.inventory_service.name
  policy_arn = aws_iam_policy.inventory.arn
}

resource "aws_iam_role" "lambda" {
  name               = "${var.project_name}-${var.environment}-notification-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}