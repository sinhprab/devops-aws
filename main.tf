terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }

  required_version = ">= 1.2.0"
}
## Selecting region for AWS infra 
provider "aws" {
  region = "eu-west-2"
}
## Creating VPC 1 
resource "aws_vpc" "VPC-1-LONDON" {
  cidr_block           = "192.168.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC-1-LONDON"
  }
}
## Creating VPC 2
resource "aws_vpc" "VPC-2-LONDON" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC-2-LONDON"
  }
}
## Creating Subnet for VPC-1-LONDON
resource "aws_subnet" "SUBNET-1-LONDON" {
  vpc_id            = aws_vpc.VPC-1-LONDON.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "SUBNET-1-LONDON"
  }
}
## Creating Subnet for VPC-2-LONDON
resource "aws_subnet" "SUBNET-2-LONDON" {
  vpc_id            = aws_vpc.VPC-2-LONDON.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "SUBNET-2-LONDON"
  }
}
## ADDING ONE EC2 INSANCE TO 1ST VPC'S SUBNET-1-LONDON
resource "aws_instance" "EC2-1-LONDON" {
  ami                         = "ami-05238ab1443fdf48f"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.SUBNET-1-LONDON.id
  vpc_security_group_ids      = [aws_security_group.SG-1-LONDON.id]
  associate_public_ip_address = true
  key_name                    = "DEV-KEY-PAIR"

  tags = {
    Name = "EC2-1-LONDON"
  }
}
## ADDING ONE EC2 INSANCE TO 2ND VPC'S SUBNET-2-LONDON
resource "aws_instance" "EC2-2-LONDON" {
  ami                         = "ami-05238ab1443fdf48f"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.SUBNET-2-LONDON.id
  vpc_security_group_ids      = [aws_security_group.SG-2-LONDON.id]
  associate_public_ip_address = true
  key_name                    = "DEV-KEY-PAIR"

  tags = {
    Name = "EC2-2-LONDON"
  }
}
## Creating Keypair 
## Adding Internet Gateway to 1st VPC
resource "aws_internet_gateway" "IGW-1-LONDON" {
  vpc_id = aws_vpc.VPC-1-LONDON.id

  tags = {
    Name = "IGW-1-LONDON"
  }
}
## Adding Route table to VPC 1 and subnet association
resource "aws_route_table" "ROUTE-1-LONDON" {
  vpc_id = aws_vpc.VPC-1-LONDON.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW-1-LONDON.id
  }

  tags = {
    Name = "ROUTE-1-LONDON"
  }
}
## Associating Route Table 1 with Subnet 1
resource "aws_route_table_association" "ASSOCIATE-1-LONDON" {
  subnet_id      = aws_subnet.SUBNET-1-LONDON.id
  route_table_id = aws_route_table.ROUTE-1-LONDON.id
}
## Adding Internet Gateway to 2nd VPC
resource "aws_internet_gateway" "IGW-2-LONDON" {
  vpc_id = aws_vpc.VPC-2-LONDON.id

  tags = {
    Name = "IGW-2-LONDON"
  }
}
## Adding Route table to VPC 2 and subnet association
resource "aws_route_table" "ROUTE-2-LONDON" {
  vpc_id = aws_vpc.VPC-2-LONDON.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW-2-LONDON.id
  }

  tags = {
    Name = "ROUTE-2-LONDON"
  }
}
## Associating Route Table 2 with Subnet 2
resource "aws_route_table_association" "ASSOCIATE-2-LONDON" {
  subnet_id      = aws_subnet.SUBNET-2-LONDON.id
  route_table_id = aws_route_table.ROUTE-2-LONDON.id
}
## Adding Security Group 1
resource "aws_security_group" "SG-1-LONDON" {
  name        = "SG-1-LONDON"
  description = "To Allow SSH and ping"
  vpc_id      = aws_vpc.VPC-1-LONDON.id

  tags = {
    Name = "SG-1-LONDON"
  }
}
## Adding Security Group 2
resource "aws_security_group" "SG-2-LONDON" {
  name        = "SG-2-LONDON"
  description = "To Allow SSH and ping"
  vpc_id      = aws_vpc.VPC-2-LONDON.id

  tags = {
    Name = "SG-2-LONDON"
  }
}
##
resource "aws_vpc_security_group_ingress_rule" "SG-1-LONDON-ALLOW-SSH" {
  security_group_id = aws_security_group.SG-1-LONDON.id
  cidr_ipv4         = "80.249.128.69/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "SG-1-LONDON-ALLOW-OUTBOUND-ALL" {
  security_group_id = aws_security_group.SG-1-LONDON.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
##
resource "aws_vpc_security_group_ingress_rule" "SG-2-LONDON-ALLOW-SSH" {
  security_group_id = aws_security_group.SG-2-LONDON.id
  cidr_ipv4         = "80.249.128.69/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "SG-2-LONDON-ALLOW-OUTBOUND-ALL" {
  security_group_id = aws_security_group.SG-2-LONDON.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
## Adding Rule to access VPC-1 & VPC2
resource "aws_vpc_security_group_ingress_rule" "SG-2-LONDON-ALLOW-ALL-VPC2" {
  security_group_id = aws_security_group.SG-2-LONDON.id
  cidr_ipv4         = "10.0.0.0/16"
  ip_protocol       = "-1"
}
## 
resource "aws_vpc_security_group_ingress_rule" "SG-1-LONDON-ALLOW-ALL-VPC2" {
  security_group_id = aws_security_group.SG-1-LONDON.id
  cidr_ipv4         = "192.168.0.0/16"
  ip_protocol       = "-1"
}
##
module "vpc_peering" {
  source = "cloudposse/vpc-peering/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version = "x.x.x"
  namespace        = "eg"
  stage            = "dev"
  name             = "VPC-1-LONDON-TO-VPC-2-LONDON"
  requestor_vpc_id = aws_vpc.VPC-1-LONDON.id
  acceptor_vpc_id  = aws_vpc.VPC-2-LONDON.id
  auto_accept      = true
  }
