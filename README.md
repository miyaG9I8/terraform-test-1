# Terraform による AWS Web サーバー構築
Terraform を用いて AWS 上に  VPC・Subnet・Internet Gateway・EC2 からなる最小構成の Web サーバー環境を構築する検証用サンプルです。
初期段階では構成を複雑にせず、EC2 が起動し、ネットワーク経由でアクセスできるところまでを明確に理解することを目的としています。

## 目的
- Terraform を用いた AWS インフラ構築の基礎理解
- IaC による再現性のあるインフラ管理の検証

## 使用技術
- Terraform
- AWS
  - VPC
  - Subnet
  - Internet Gateway
  - Route Table
  - Security Group
  - EC2

## ディレクトリ構成 
```
├── .gitignore
├── .terraform.lock.hcl
├── terraform.tfvars # ※ Git 管理対象外
├── README.md
└── main.tf
```

## terraform操作コマンド
#初期化<br>
terraform init

#実行前の確認<br>
terraform plan

#実行<br> 
terraform apply

#構築した環境の破棄<br> 
terraform destroy

## 今後の改善予定
- Private Subnet + ALB 構成への拡張
- マルチAZへの拡張
