resource "aws_cloudwatch_log_group" "this" {

  name              = "/ecs/${var.project_name}/${var.service_name}"
  retention_in_days = 7

}

resource "aws_ecs_task_definition" "this" {

  family                   = "${var.project_name}-${var.service_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = var.cpu
  memory = var.memory

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = var.service_name
      image = var.container_image

      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = var.environment_variables

      logConfiguration = {

        logDriver = "awslogs"

        options = {

          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = "ap-south-1"
          awslogs-stream-prefix = "ecs"

        }

      }

    }
  ])

}

resource "aws_ecs_service" "this" {

  name            = var.service_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn

  desired_count = var.desired_count
  launch_type   = "FARGATE"

  network_configuration {

    subnets = var.subnet_ids

    security_groups = var.security_group_ids

    assign_public_ip = var.assign_public_ip

  }

  lifecycle {
  ignore_changes = [
    task_definition
  ]
}

deployment_controller {
  type = "ECS"
}

  load_balancer {

    target_group_arn = var.target_group_arn

    container_name = var.service_name

    container_port = var.container_port

  }

  depends_on = [
    aws_ecs_task_definition.this
  ]

}