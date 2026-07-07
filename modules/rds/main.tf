resource "random_password" "db" {
  length           = 20
  special          = true
  override_special = "!#$%^&*()-_=+[]{}:?"
}

resource "aws_secretsmanager_secret" "db" {

  name = "${var.project_name}-${var.environment}-db-secret"
}

resource "aws_secretsmanager_secret_version" "db" {

  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({

    username = var.db_username

    password = random_password.db.result
  })
}


resource "aws_db_subnet_group" "this" {

  name = "${var.project_name}-${var.environment}-db-subnets"

  subnet_ids = var.private_subnet_ids

  tags = {

    Name = "${var.project_name}-${var.environment}-db-subnets"
  }
}

resource "aws_db_instance" "postgres" {

  identifier = "${var.project_name}-${var.environment}"

  engine = "postgres"

  engine_version = "17"

  instance_class = "db.t3.micro"

  allocated_storage = 20

  storage_type = "gp3"

  storage_encrypted = true

  db_name = var.db_name

  username = var.db_username

  password = random_password.db.result

  db_subnet_group_name = aws_db_subnet_group.this.name

  vpc_security_group_ids = [

    var.rds_security_group_id
  ]

  publicly_accessible = false

  multi_az = false

  backup_retention_period = 1

  skip_final_snapshot = true

  deletion_protection = false
}