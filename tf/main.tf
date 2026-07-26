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
  access_key = var.access_key
  secret_key = var.secret_key
}

# --------------Single Server Deployment--------------
# resource "aws_security_group" "web_server_security_group" {
#   name = "web-server-security-group"
#   description = "Security group for web server"

#   ingress {
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port = 80
#     to_port = 80
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port = 3000
#     to_port = 3000
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port = 5000
#     to_port = 5000
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "web-server-security-group"
#   }
# }

# resource "aws_instance" "web" {
#   ami           = "ami-0b6d9d3d33ba97d99"
#   instance_type = "t2.micro"
#   vpc_security_group_ids = [aws_security_group.web_server_security_group.id]
  
#   tags = {
#     Name = "frontend-backend-server"
#   }
#   user_data = file("frontend-backend.sh")

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

resource "aws_instance" "frontend" {
  ami = "ami-0b6d9d3d33ba97d99"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_server_security_group.id]
  tags = {
    Name = "frontend-server"
  }
  user_data = templatefile("frontend.sh", {
    BACKEND_PUBLIC_IP = aws_instance.backend.public_ip
  })
}

resource "aws_instance" "backend" {
  ami = "ami-0b6d9d3d33ba97d99"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_server_security_group.id]
  tags = {
    Name = "backend-server"
  }
  user_data = file("backend.sh")
}

output "frontend_public_ip" {
  value = aws_instance.frontend.public_ip
}

output "backend_public_ip" {
  value = aws_instance.backend.public_ip
}
