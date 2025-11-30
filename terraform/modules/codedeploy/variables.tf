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

###############################################
# ECS Service (CodeDeploy が操作する対象)
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
# ALB Listeners (Blue/Green 用)
###############################################
variable "production_listener_arn" {
  description = "ALB production listener ARN"
  type        = string
}

variable "test_listener_arn" {
  description = "ALB test listener ARN"
  type        = string
}

###############################################
# Target Groups (Blue / Green)
###############################################
variable "blue_target_group_name" {
  description = "Blue target group name"
  type        = string
}

variable "green_target_group_name" {
  description = "Green target group name"
  type        = string
}

###############################################
# Tags
###############################################
variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
