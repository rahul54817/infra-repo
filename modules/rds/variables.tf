variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "rds_security_group_id" {
  type = string
}

variable "db_name" {
  type = string
  default = "order_management"
}

variable "db_username" {
  type    = string
  default = "dbadmin"
}