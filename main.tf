terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
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