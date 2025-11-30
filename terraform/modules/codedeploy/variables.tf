###############################################
# Basic
###############################################
variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/stg/prod)"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

###############################################
# ECS Service Info
###############################################
variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "service_name" {
  description = "ECS service name"
  type        = string
}

###############################################
# ALB / Blue-Green
###############################################
variable "production_listener_arn" {
  description = "ARN of production listener"
  type        = string
}

variable "test_listener_arn" {
  description = "ARN of test listener"
  type        = string
}

variable "blue_target_group_name" {
  description = "Blue target group name"
  type        = string
}

variable "green_target_group_name" {
  description = "Green target group name"
  type        = string
}

###############################################
# Deployment Behavior
###############################################
variable "termination_wait_time_in_minutes" {
  description = "How long to keep blue tasks alive after successful deployment"
  type        = number
  default     = 5
}

variable "deployment_ready_wait_time_in_minutes" {
  description = "How long to wait before continuing deployment automatically"
  type        = number
  default     = 0
}
