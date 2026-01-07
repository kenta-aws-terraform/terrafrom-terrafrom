# 1. タイトルと概要
### AWS上に構築するコンテナアプリケーション基盤

このリポジトリでは、AWS上にコンテナアプリケーションの実行基盤を構築するためのTerraformを構築しました。
主にAmazon ECS（Fargate）を採用し、インターネット公開用にApplication Load Balancerを構築します。  
また、CodeDeployを用いたBlue/Greenデプロイ構成を採用しています。
可用性・運用性・再現性を高めて、同様のインフラストラクチャを再現する際のベースラインとして利用できます。

# 2. プロジェクトの目的と設計ポイント
### このプロジェクトの目的

このプロジェクトでは、AWSとTerraformを使って本番運用を想定したコンテナ基盤を構築しました。ただアプリを動かすだけでなく、以下のような実務で求められるような要素を意識して設計しています。

- ECS Fargateによるコンテナアプリケーションの安定稼働  
- Blue/Greenデプロイによる無停止リリースの実現  
- セキュリティとコストを両立したネットワーク設計  
- Terraformによる再現可能なインフラ構成

### 設計ポイント

#### 冗長性と拡張性
VPCをマルチAZ構成にし、PublicサブネットにALB、PrivateサブネットにECS Fargateタスクを配置することで、外部からの直接アクセスを防ぎつつ可用性を確保しています。

#### 安全なデプロイフロー
CodeDeployのBlue/Greenデプロイを採用し、新しいバージョンを本番トラフィックに流す前に検証用トラフィックで検証できるようにしました。また、問題発生時にはロールバックも容易に行うことが出来ます。

#### 運用しやすいコード管理
Terraformでモジュール化し、環境ごとのパラメータを変数で管理することで、コードの再利用性とメンテナンス性を高めています。

#### コスト最適化
開発環境ではNAT Gatewayを1つに絞るなど、実務で意識した方がよさそうなコスト削減も考慮した設計になっています。

# 3. システム構成図
![System Architecture](images/architecture.png)

# 4. 技術スタック
### Infrastructure as Code
- Terraform
###  AWS Services
- Amazon VPC
- Application Load Balancer
- Amazon ECS (Fargate)
- Amazon ECR
- AWS CodeDeploy (ECS Blue/Green)
- AWS IAM
- Amazon CloudWatch Logs
- VPC Endpoint (Interface / Gateway)
- NAT Gateway
### Region
- ap-northeast-1 (東京)

# 5. 環境構築・再現手順
本リポジトリには、AWS上のインフラ構成をTerraformで定義しています。  
以下の手順で、同じ構成の環境を構築できます。

### 前提条件
以下の環境が事前に準備されていることを前提とします。

- AWSアカウント
- AWS CLI
- Terraform

### 環境構築手順
1. リポジトリをクローン後、対象の環境のディレクトリに移動します。  
`git clone <https://github.com/kenta-aws-terraform/terrafrom-terrafrom.git>  `  
`cd terraform/envs/dev`

2. Terraform の初期化を行います。  
`terraform init`

3. 構築する内容を事前に確認します。  
`terraform plan`

4. 問題がなければ、以下を実行してリソースを作成します。  
`terraform apply`

### 構築後の確認

Terraformのapply完了後、以下が作成されていることを確認します。 

- VPCおよびPublic / Privateサブネット
- Application Load Balancer
- ECS Cluster / Service（Fargate）
- Target Group（Blue / Green）
- 関連するIAM Role / Security Group

AWSマネジメントコンソールから各リソースの状態を確認できます。

### リソース削除手順
作成したリソースを削除したい場合は以下を実行します。  
`terraform destroy`

# 6. 工夫した点
### 1. ネットワーク構成とセキュリティ境界を明確に分離した点
ALBはPublic Subnet、ECS FargateはPrivate Subnetに配置し、コンテナへの直接アクセスを防ぐ構成にしました。実務ではインターネット公開するものは最小限にするが基本だと考えているので、ALBだけをパブリックに公開し、アプリケーション本体は内部ネットワークに隠すようにしました。

### 2. Blue/Greenデプロイを前提とした構成にした点
CodeDeployを利用したBlue/Greenデプロイを採用し、
新バージョンを本番トラフィックに流す前に検証できる構成としました。
実務では本番環境が落ちることは絶対に避けたいのでBlue/Greenデプロイを採用しました。

### 3. Terraformの再利用性を意識したモジュール構成
Network/ALB/ECS/CodeDeployをそれぞれモジュールとして分離し、将来的に環境の追加や構成の変更が発生した場合でも、影響範囲を最小限に抑えられることを意識しました。

### 4. 開発環境を想定したコスト最適化
開発環境では、コストを抑えることを優先し、NAT Gatewayは単一構成にしました。その上で、可用性を落とさないバランスを意識しました。
本番環境を想定する場合には、要件に応じてAZごとにNAT Gatewayを配置する構成へ拡張できるようにしています。

# 7. 今後の展望
### 1. CI/CDパイプラインでの自動化
今回はインフラ構築に集中したので、アプリケーションのビルドやデプロイは手動前提にしていますが、実務では自動化が必須だと思っています。GitHub ActionsやCodePipelineと連携して、コードのプッシュからイメージビルド、デプロイまで自動化できるようにしていきたいです。

### 2. 監視・運用の仕組みを充実させる
CloudWatch Logsでログは集めていますが、それだけだと「何か起きてから気づく」形になってしまいます。メトリクス監視やアラート設定を追加して、CPU使用率などの異常やエラーログの急増を自動検知できるようにしたいと考えています。

### 3. 環境分離とセキュリティ設計の拡張
現状は単一アカウント・単一環境ですが、本番を想定するなら開発/ステージング/本番でアカウントを分けたり、IAM権限をもっと細かく設計する必要があると思っています。大規模な運用を想定した構成にも対応できるようにしていきたいと思っています。

