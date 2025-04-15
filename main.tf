terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}
## Selecting region for AWS infra 
provider "aws" {
  region = "eu-west-2"
}
## Adding registered domain to terraform state and adding Tag to same  
resource "aws_route53domains_registered_domain" "redhill" {
  domain_name = "redhill.click"

  tags = {
    Environment = "test"
  }

}
## Defining A Name to my Domain with hard coded Ip and Zone Id of created Domain ##
resource "aws_route53_record" "www" {
  zone_id = "Z0791921349KGZWX4W5VG"
  name    = "www.redhill.click"
  type    = "A"
  ttl     = 300
  records = ["2.2.2.2"]
}
## Defining C Name to my Domain with hard coded Ip and Zone Id of created Domain ##
resource "aws_route53_record" "www-c" {
  zone_id = "Z0791921349KGZWX4W5VG"
  name    = "www-c.redhill.click"
  type    = "CNAME"
  ttl     = 300
  records = ["redhill.click"]
}
## Adding TXT Record entry to my Domian "redhill.click"
resource "aws_route53_record" "text-record" {
  zone_id = "Z0791921349KGZWX4W5VG"
  name    = "redhill.click"
  type    = "TXT"
  ttl     = 300
  records = ["This Domain Belongs to Pranshu Sinha Created for learning Purpose"]
}
## Adding EC2 Insance 
resource "aws_instance" "EC2" {
  ami           = "ami-05238ab1443fdf48f"
  instance_type = "t2.micro"

  tags = {
    Name = "Basic_EC2_ServerInstance"
  }
}
## Adding S3 Bucket 
resource "aws_s3_bucket" "test-s3-bucket" {
  bucket = "sinha2509-test-bucket"

  tags = {
    Name        = "S3 Basic bucket"
    Environment = "test"
  }
}
## Creating an EBS Volume
resource "aws_ebs_volume" "additional-ebs-volume" {
  availability_zone = "eu-west-2b"
  size              = 5

  tags = {
    Name = "test"
  }
}
## Atching Created EBS to Existing EC2 instance 
resource "aws_volume_attachment" "attach-to-EC2" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.additional-ebs-volume.id
  instance_id = aws_instance.EC2.id
}