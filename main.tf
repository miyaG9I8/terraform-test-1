# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-1"
  profile ="terraform-test-1"
}

variable "vpc_cidr"{
    type = string
}

#1 VPC作成
resource "aws_vpc" "iac-vpc" {
  cidr_block       = var.vpc_cidr
  tags = {
    Name = "iac-vpc"
  }
}

#2 インターネットゲートウェイ作成
resource "aws_internet_gateway" "iac-gateway" {
  vpc_id = aws_vpc.iac-vpc.id
  tags = {
    Name = "iac-gateway"
  }
}

variable "route_table_cidr"{
    type = string
}

#3 ルートテーブル作成
resource "aws_route_table" "iac-route-table" {
  vpc_id = aws_vpc.iac-vpc.id
  route {
    cidr_block = var.route_table_cidr
    gateway_id = aws_internet_gateway.iac-gateway.id
  }
#   route {
#     ipv6_cidr_block        = "::/0"
#     gateway_id = aws_internet_gateway.iac-gateway.id
#   }
  tags = {
    Name = "iac-route-table"
  }
}

variable "subnet_cidr" {
    type = string
}

#4 サブネット作成
resource "aws_subnet" "iac-subnet" {
  vpc_id     = aws_vpc.iac-vpc.id
  cidr_block = var.subnet_cidr
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "iac-subnet"
  }
}

#5 サブネットとルートテーブルの紐付け
resource "aws_route_table_association" "iac-association" {
  subnet_id      = aws_subnet.iac-subnet.id
  route_table_id = aws_route_table.iac-route-table.id
}

variable "security_groups_cidr" {
    type = list(string)
}

#6 セキュリティグループ作成（ポート22,80,443許可）
resource "aws_security_group" "iac-security-group" {
  name        = "iac-security-group"
  description = "Allow web "
  vpc_id      = aws_vpc.iac-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = var.security_groups_cidr
  }
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.security_groups_cidr
  }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.security_groups_cidr
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = var.security_groups_cidr
  }
  tags = {
    Name = "iac-security-group"
  }
}

variable "eni_eip_privateip" {
    type = string
}

#7 ENI（Elastic Network Interface）作成（サブネット、セキュリティグループ等を１つにまとめる）
resource "aws_network_interface" "iac-nw-interface" {
  subnet_id       = aws_subnet.iac-subnet.id
  private_ips     = [var.eni_eip_privateip]
  security_groups = [aws_security_group.iac-security-group.id]
}

#8 EIP（Elastic IP）作成、ENIに紐付け
resource "aws_eip" "iac-eip" {
  network_interface         = aws_network_interface.iac-nw-interface.id
  associate_with_private_ip = var.eni_eip_privateip
  depends_on = [aws_internet_gateway.iac-gateway, aws_instance.iac-instance]
}

#9 Webサーバー構築（Linuxサーバー構築、Apacheインストール、index.html作成）
resource "aws_instance" "iac-instance" {
  ami = "ami-06cce67a5893f85f9"
  instance_type = "t3.micro"
  availability_zone = "ap-northeast-1a"
  key_name = "iac-key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.iac-nw-interface.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum -y install httpd
              sudo systemctl start httpd.service
              sudo bash -c 'echo 初めてのTerraform！ > /var/www/html/index.html'
              EOF
  tags = {
    Name = "iac-instance"
    Env = "dev"
  }
}








