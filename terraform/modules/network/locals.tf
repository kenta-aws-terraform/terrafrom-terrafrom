locals {
  # リソース名を環境単位で一貫させるためのプレフィックス
  name_prefix = "${var.project}-${var.environment}"

  # 全リソースに共通で付与するタグ
  common_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  # サブネット CIDR と AZ を対応付けた定義（index で整列）
  public_subnets = {
    for idx, cidr in var.public_subnet_cidrs :
    idx => {
      cidr = cidr
      az   = data.aws_availability_zones.available.names[idx]
      tier = "public"
    }
  }

  private_subnets = {
    for idx, cidr in var.private_subnet_cidrs :
    idx => {
      cidr = cidr
      az   = data.aws_availability_zones.available.names[idx]
      tier = "private"
    }
  }

  # Fargate / ECS Exec で必要となる Interface VPC Endpoint（PrivateLink）
  interface_endpoint_services = [
    "ecr.api",
    "ecr.dkr",
    "logs",
    "ssmmessages",
  ]
}
