variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}

variable "inventory_queue_arn" {
  type = string
}

variable "notification_queue_arn" {
  type = string
}