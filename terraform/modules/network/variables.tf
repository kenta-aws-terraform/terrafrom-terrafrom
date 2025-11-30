###############################################
# 基本情報
###############################################
variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/stg/prod)"
  type        = string
}

variable "region" {
  description = "AWS region (e.g. ap-northeast-1)"
  type        = string
}

###############################################
# VPC
###############################################
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

###############################################
# Subnets & AZ
###############################################
variable "azs" {
  description = "List of Availability Zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}



###############################################
# Tags
###############################################
variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

variable "single_nat" {
  description = "Use single NAT gateway for cost savings"
  type        = bool
  default     = true
}


