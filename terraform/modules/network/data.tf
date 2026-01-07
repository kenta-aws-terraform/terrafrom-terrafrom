# リージョンおよび利用可能な AZ 情報を取得
data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}
