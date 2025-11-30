locals {
  # リソース名の共通プレフィックス
  name_prefix = "${var.project}-${var.environment}"

  # 共通タグ
  common_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  # public / private サブネット情報に AZ を紐付けたマップ
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

  # Fargate + ECS Exec 用の Interface VPC エンドポイント（ec2messages は含めない）
  interface_endpoint_services = [
    "ecr.api",
    "ecr.dkr",
    "logs",
    "ssmmessages",
  ]
}
