###############################################
# Basic
###############################################
variable "project" {
  type = string
}

variable "environment" {
  type = string
}

###############################################
# Network
###############################################
# ❌ vpc_id は不要 → 削除済
variable "private_subnet_ids" {
  type = list(string)
}

###############################################
# ALB / Blue-Green Routing
###############################################
variable "alb_security_group_id" {
  type = string
}

variable "blue_target_group_arn" {
  type = string
}

###############################################
# Container Image (ECR / fallback)
###############################################
variable "ecr_repository_name" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "use_public_image" {
  type    = bool
  default = false
}

###############################################
# Container Settings
###############################################
variable "container_name" {
  type = string
}

variable "container_port" {
  type = number
}

variable "cpu" {
  type = string
}

variable "memory" {
  type = string
}

variable "desired_count" {
  type = number
}

variable "assign_public_ip" {
  type    = bool
  default = false
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

###############################################
# Tags
###############################################
variable "tags" {
  type    = map(string)
  default = {}
}
