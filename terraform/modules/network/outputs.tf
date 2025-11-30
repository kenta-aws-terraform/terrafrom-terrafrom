output "vpc_id" {
  description = "作成された VPC の ID"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "VPC の CIDR"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "パブリックサブネットの ID 一覧"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "プライベートサブネットの ID 一覧"
  value       = [for s in aws_subnet.private : s.id]
}

output "nat_gateway_ids" {
  description = "NAT Gateway の ID（有効な場合）"
  value       = [for ngw in aws_nat_gateway.this : ngw.id]
}

output "vpc_endpoint_ids" {
  description = "VPC エンドポイントの ID 一覧（S3 + Interface）"
  value = {
    s3        = aws_vpc_endpoint.s3.id
    interface = { for k, ep in aws_vpc_endpoint.interface : k => ep.id }
  }
}
