# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-vpc"
  })
}

# Internet Gateway（Public からの外部接続用）
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-igw"
  })
}

# Public Subnets（ALB 配置用）
resource "aws_subnet" "public" {
  for_each = {
    for idx, cidr in var.public_subnet_cidrs :
    tostring(idx) => {
      cidr = cidr
      az   = var.azs[idx]
    }
  }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-public-${each.key}"
  })
}

# Private Subnets（ECS/Fargate 配置用）
resource "aws_subnet" "private" {
  for_each = {
    for idx, cidr in var.private_subnet_cidrs :
    tostring(idx) => {
      cidr = cidr
      az   = var.azs[idx]
    }
  }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-private-${each.key}"
  })
}

# NAT Gateway 用の EIP
resource "aws_eip" "nat" {
  # single_nat=true の場合は 1 つに集約する
  for_each = var.single_nat ? { "0" = {} } : { for k in keys(aws_subnet.public) : k => {} }

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-nat-eip-${each.key}"
  })
}

# NAT Gateway（Private からのアウトバウンド用）
resource "aws_nat_gateway" "this" {
  # single_nat=true の場合は 1 つに集約する
  for_each = var.single_nat ? { "0" = {} } : { for k in keys(aws_subnet.public) : k => {} }

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = var.single_nat ? aws_subnet.public["0"].id : aws_subnet.public[each.key].id

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-nat-${each.key}"
  })
}

# Public Route Table（0.0.0.0/0 → IGW）
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-public-rt"
  })
}

# Public Route Table Association
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id
}

# Private Route Table（0.0.0.0/0 → NAT）
resource "aws_route_table" "private" {
  # single_nat=true の場合は Private RT も 1 つに集約する
  for_each = var.single_nat ? { "0" = {} } : { for k in keys(aws_subnet.private) : k => {} }

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[var.single_nat ? "0" : each.key].id
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-private-rt-${each.key}"
  })
}

# Private Route Table Association
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  route_table_id = var.single_nat ? aws_route_table.private["0"].id : aws_route_table.private[each.key].id
  subnet_id      = each.value.id
}

# Interface VPC Endpoints（PrivateLink）
locals {
  interface_endpoints = {
    ecs           = "com.amazonaws.${var.region}.ecs"
    ecs_telemetry = "com.amazonaws.${var.region}.ecs-telemetry"
    ecr_api       = "com.amazonaws.${var.region}.ecr.api"
    ecr_dkr       = "com.amazonaws.${var.region}.ecr.dkr"
    logs          = "com.amazonaws.${var.region}.logs"
    ssmmessages   = "com.amazonaws.${var.region}.ssmmessages"
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_endpoints

  vpc_id              = aws_vpc.this.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.private : s.id]
  private_dns_enabled = true

  security_group_ids = [aws_security_group.vpce.id]

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-vpce-${each.key}"
  })
}

# Security Group for Interface VPC Endpoints
resource "aws_security_group" "vpce" {
  name        = "${var.project}-${var.environment}-vpce-sg"
  description = "Security group for interface VPC Endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-vpce-sg"
  })
}

# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [for rt in aws_route_table.private : rt.id]

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-s3-endpoint"
  })
}
