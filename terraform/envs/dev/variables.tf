# 共通識別子
# リソース命名や環境識別に使用する
variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "region" {
  type        = string
  description = "AWS region"
}

# Network
variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type        = list(string)
  description = "List of AZs to use"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Must align with azs"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Must align with azs"
}

variable "single_nat" {
  type        = bool
  description = "Whether to create a single NAT gateway"
  default     = true
}

# Tags
variable "tags" {
  type    = map(string)
  default = {}
}

# ECS/Container
variable "ecr_repository_name" {
  type        = string
  description = "ECR repository name"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag"
}

variable "use_public_image" {
  type        = bool
  default     = false
  description = "Use a public image for initial apply"
}

variable "container_name" {
  type    = string
  default = "app"
}

variable "container_port" {
  type    = number
  default = 80
}

variable "cpu" {
  type    = string
  default = "256"
}

variable "memory" {
  type    = string
  default = "512"
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}
