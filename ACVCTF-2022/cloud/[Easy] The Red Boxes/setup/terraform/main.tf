terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 3.37"
    }
  }
}

provider "aws" {
  region                  = "us-east-2"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
}

variable "region" {
  default = "us-east-2"
  type = string
}

resource "random_id" "bucket-id" {
  byte_length = 8
}

resource "aws_s3_bucket" "b" {
  bucket = "state-secrets-${random_id.bucket-id.hex}"
  acl = "private"
}

resource "aws_s3_bucket_object" "flag" {
  bucket = aws_s3_bucket.b.id
  acl = "private"
  key = "flag.txt"
  source = "files/flag.txt"
}

resource "aws_s3_bucket_object" "public_key" {
  bucket = aws_s3_bucket.b.id
  acl = "private"
  key = "func_adm/id_rsa.pub"
  source = "files/func_adm/id_rsa.pub"
}

resource "aws_s3_bucket_object" "private_key" {
  bucket = aws_s3_bucket.b.id
  acl = "private"
  key = "func_adm/id_rsa"
  source = "files/func_adm/id_rsa"
}