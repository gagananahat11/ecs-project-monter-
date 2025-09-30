provider "aws" { region = var.aws_region }

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = { Name = "ecs-monitoring-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 0)
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route { cidr_block = "0.0.0.0/0", gateway_id = aws_internet_gateway.igw.id }
}

resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ecs_sg" {
  name = "ecs-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 80; to_port = 80; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443; to_port = 443; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 3000; to_port = 3000; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"]
    description = "app port (if you need direct)"
  }
  egress { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_ecr_repository" "app" {
  name = "ecs-sample-app"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecs_cluster" "cluster" {
  name = "ecs-sample-cluster"
}

# IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_exec" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    effect = "Allow"
    principals { type = "Service"; identifiers = ["ecs-tasks.amazonaws.com"] }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_policy" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# EC2 monitoring instance
resource "aws_instance" "monitoring" {
  ami = data.aws_ami.al2.id
  instance_type = var.monitoring_instance_type
  subnet_id = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]
  key_name = var.public_key_name
  user_data = file("${path.module}/user_data_monitoring.sh")
  tags = { Name = "monitoring-instance" }
}

data "aws_ami" "al2" {
  most_recent = true
  filter { name = "name"; values = ["amzn-ami-hvm-*-x86_64-gp2"] }
  owners = ["amazon"]
}
