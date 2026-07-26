terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.0.0"
}

locals {
  endpoint = "http://localhost:4566"
}

provider "aws" {
  region = "us-east-1"

  # endpoints {
  #   s3       = local.endpoint
  #   ec2      = local.endpoint
  #   sts      = local.endpoint
  #   iam      = local.endpoint
  #   lambda   = local.endpoint
  #   dynamodb = local.endpoint
  #   sqs      = local.endpoint
  #   sns      = local.endpoint
  #   ecr      = local.endpoint
  #   ecs      = local.endpoint
  #   logs     = local.endpoint
  #   events   = local.endpoint
  #   ssm       = local.endpoint
  #   secretsmanager = local.endpoint
  # }

  # skip_credentials_validation = true
  # skip_metadata_api_check     = true
  # skip_requesting_account_id  = true
}

# resource "aws_s3_bucket" "tf_state_bucket" {
#   bucket = "tf-state-bucket-test"
# }

# resource "aws_s3_bucket_acl" "tf_state_bucket_acl" {
#   bucket = aws_s3_bucket.tf_state_bucket.id
#   acl    = "private"
# }

resource "aws_security_group" "web_server_security_group" {
  name = "web-server-security-group"
  description = "Security group for web server"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-security-group"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0b6d9d3d33ba97d99"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_server_security_group.id]
  
  tags = {
    Name = "frontend-backend-server"
  }
  user_data = file("frontend-backend.sh")

}

output "instance_public_ip" {
  description = "The public IP address of the web server"
  value       = aws_instance.web.public_ip
}