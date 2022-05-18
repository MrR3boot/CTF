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

resource "aws_iam_role" "lambda_role" {
name   = "LambdaExecutionRole"
assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda" {
 
 name         = "lambda_iam_policy"
 path         = "/"
 policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents",
       "dynamodb:ListTables",
       "dynamodb:Scan"
     ],
     "Resource": [ "arn:aws:logs:*:*:*", "*" ],
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

resource "aws_lambda_function" "terraform_lambda_func" {
filename                       = "${path.module}/code.zip"
function_name                  = "StatusChecker"
role                           = aws_iam_role.lambda_role.arn
handler                        = "index.handler"
runtime                        = "nodejs14.x"
depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}

resource "aws_dynamodb_table" "dynamodb-table" {
  name           = "Records"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

}

resource "aws_dynamodb_table_item" "item1" {
  table_name = aws_dynamodb_table.dynamodb-table.name
  hash_key   = aws_dynamodb_table.dynamodb-table.hash_key

  item = <<ITEM
{
  "id": {"S": "1"},
  "name": {"S": "Sergio aka The Professor"}
}
ITEM
}

resource "aws_dynamodb_table_item" "item2" {
  table_name = aws_dynamodb_table.dynamodb-table.name
  hash_key   = aws_dynamodb_table.dynamodb-table.hash_key

  item = <<ITEM
{
  "id": {"S": "2"},
  "name": {"S": "Oliveira aka Tokyo"}
}
ITEM
}

resource "aws_dynamodb_table_item" "item3" {
  table_name = aws_dynamodb_table.dynamodb-table.name
  hash_key   = aws_dynamodb_table.dynamodb-table.hash_key

  item = <<ITEM
{
  "id": {"S": "3"},
  "name": {"S": "Fonollosa aka Berlin"}
}
ITEM
}

resource "aws_dynamodb_table_item" "item4" {
  table_name = aws_dynamodb_table.dynamodb-table.name
  hash_key   = aws_dynamodb_table.dynamodb-table.hash_key

  item = <<ITEM
{
  "id": {"S": "4"},
  "name": {"S": "Jiménez aka Nairobi"}
}
ITEM
}

resource "aws_dynamodb_table_item" "item5" {
  table_name = aws_dynamodb_table.dynamodb-table.name
  hash_key   = aws_dynamodb_table.dynamodb-table.hash_key

  item = <<ITEM
{
  "id": {"S": "5"},
  "name": {"S": "Bandera aka flag - ACVCTF{4lph4_b3t4_g4mm4_l4mbda_0ops!}"}
}
ITEM
}

resource "aws_dynamodb_table" "airflowdb" {
  name           = "airflow"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

}

resource "aws_dynamodb_table_item" "cred" {
  table_name = aws_dynamodb_table.airflowdb.name
  hash_key   = aws_dynamodb_table.airflowdb.hash_key

  item = <<ITEM
{
  "id": {"S": "1"},
  "username": {"S": "tamayo"},
  "password": {"S": "Fy[BpGD5M;F(Rnj["}
}
ITEM
}
