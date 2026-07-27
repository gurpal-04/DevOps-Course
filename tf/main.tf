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

# --------------Multiple Server Deployment--------------
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

# resource "aws_instance" "frontend" {
#   ami = "ami-0b6d9d3d33ba97d99"
#   instance_type = "t2.micro"
#   vpc_security_group_ids = [aws_security_group.web_server_security_group.id]
#   tags = {
#     Name = "frontend-server"
#   }
#   user_data = templatefile("frontend.sh", {
#     BACKEND_PUBLIC_IP = aws_instance.backend.public_ip
#   })
# }

# resource "aws_instance" "backend" {
#   ami = "ami-0b6d9d3d33ba97d99"
#   instance_type = "t2.micro"
#   vpc_security_group_ids = [aws_security_group.web_server_security_group.id]
#   tags = {
#     Name = "backend-server"
#   }
#   user_data = file("backend.sh")
# }

# output "frontend_public_ip" {
#   value = aws_instance.frontend.public_ip
# }

# output "backend_public_ip" {
#   value = aws_instance.backend.public_ip
# }


# --------------ECS Deployment--------------
resource "aws_ecs_cluster" "frontend_backend_cluster" {
  name = "frontend-backend-cluster"
}

resource "aws_ecs_task_definition" "frontend_backend_task" {
  family                   = "frontend-backend-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"  
  memory                   = "512"  

  container_definitions = jsonencode([
    {
      name      = "frontend-backend-container"
      image     = "frontend-backend:latest"   
      essential = true
      memory    = 256                     
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/frontend-backend"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  task_role_arn = aws_iam_role.frontend_backend_task_role.arn
  execution_role_arn = aws_iam_role.frontend_backend_task_role.arn
}

resource "aws_iam_role" "frontend_backend_task_role" {
  name = "frontend-backend-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "frontend_backend_task_policy" {
  name = "frontend-backend-task-policy"
  role = aws_iam_role.frontend_backend_task_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "ecs:RunTask"
        Effect = "Allow"
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  count                     = length(var.public_subnet_cidrs)
  vpc_id                    = aws_vpc.main.id
  cidr_block                = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch   = true
  availability_zone         = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-pub-${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.project_name}-rt-public"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow inbound HTTP from the world"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.project_name}-ecs-sg"
  description = "Allow inbound from ALB on container ports"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Ingress from ALB to Flask"
    from_port   = var.backend_container_port
    to_port     = var.backend_container_port
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "Ingress from ALB to Express"
    from_port   = var.frontend_container_port
    to_port     = var.frontend_container_port
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ecs-sg"
  }
}

resource "aws_ecr_repository" "backend" {
  name = "${var.project_name}-backend"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "${var.project_name}-backend-repo"
  }
}

resource "aws_ecr_repository" "frontend" {
  name = "${var.project_name}-frontend"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "${var.project_name}-frontend-repo"
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-ecs-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

/* Managed policy that gives the task permission to pull from ECR, write logs, etc. */
resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

/* (Optional) Additional custom policy – you can attach anything your containers need */
resource "aws_iam_policy" "custom_task_policy" {
  name        = "${var.project_name}-custom-task-policy"
  description = "Custom permissions for our tasks (currently empty – add as needed)"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "custom" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.custom_task_policy.arn
}

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project_name}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = "backend"
    image     = "${aws_ecr_repository.backend.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = var.backend_container_port
      protocol      = "tcp"
    }]
  }])
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project_name}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = "frontend"
    image     = "${aws_ecr_repository.frontend.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = var.frontend_container_port
      protocol      = "tcp"
    }]
    environment = [
      {
        name  = "BACKEND_URL"
        # The ALB will forward /backend/* to the Flask service; we expose the full URL here.
        value = "http://${aws_lb.app_alb.dns_name}"
      }
    ]
  }])
}

resource "aws_lb" "app_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "${var.project_name}-alb"
  }
}

/* Target group for Flask backend */
resource "aws_lb_target_group" "backend_tg" {
  name        = "${var.project_name}-tg-backend"
  port        = var.backend_container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

/* Target group for Express frontend */
resource "aws_lb_target_group" "frontend_tg" {
  name        = "${var.project_name}-tg-frontend"
  port        = var.frontend_container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

/* Listener on port 80 (HTTP) */
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

/* Route /backend* (or /submit-form, /health) → Flask backend */
resource "aws_lb_listener_rule" "backend_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }

  condition {
    path_pattern {
      values = ["/backend/*", "/submit-form", "/health"]
    }
  }
}

/* All other traffic → Express frontend */
resource "aws_lb_listener_rule" "frontend_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_ecs_service" "backend" {
  name            = "${var.project_name}-backend-svc"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend_tg.arn
    container_name   = "backend"
    container_port   = var.backend_container_port
  }

  depends_on = [aws_lb_listener_rule.backend_rule]
}

resource "aws_ecs_service" "frontend" {
  name            = "${var.project_name}-frontend-svc"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_tg.arn
    container_name   = "frontend"
    container_port   = var.frontend_container_port
  }

  depends_on = [aws_lb_listener_rule.frontend_rule]
}