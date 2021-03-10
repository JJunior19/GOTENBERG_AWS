data "aws_region" "region_current" {}
data "aws_caller_identity" "current" {
}
data "aws_vpc" "default_vpc" {
  id="vpc-8d24fcf4"
}

data "aws_subnet_ids" "subnet_ids" {
  vpc_id = "vpc-8d24fcf4"
}
data "aws_subnet" "subnet" {
  for_each = data.aws_subnet_ids.subnet_ids.ids
  id       = each.value
}

resource "aws_ecs_cluster" "gotenberg_cluster" {
    name="uoc-${var.app_env}-gotenberg-cluster-${var.uocenv}"
}

resource "aws_iam_role" "ecs_task_execution_role" {
    name = "uoc-${var.app_env}-gotenberg-ecs-task-execution-role-${var.uocenv}"
    assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
    "Action": "sts:AssumeRole",
    "Principal": {
    "Service": "ecs-tasks.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
}
]
}
    EOF
}


resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "gotenberg-ecs-service" {
    name= "uoc-${var.app_env}-gotenberg-ecs-service-${var.uocenv}"
    cluster = aws_ecs_cluster.gotenberg_cluster.id
    task_definition = aws_ecs_task_definition.gotenberg-ecs-task.arn
    launch_type = "FARGATE"
    network_configuration {
      security_groups = [ aws_security_group.ecs_tasks.id]
      subnets=[for s in data.aws_subnet.subnet : s.id]
      assign_public_ip=true
    }
    desired_count = 1
}
resource "aws_security_group" "ecs_tasks" {
  name   = "uoc-${var.app_env}-gotenberg-security-group-${var.uocenv}"
  vpc_id = data.aws_vpc.default_vpc.id

  ingress {
    protocol         = "tcp"
    from_port        = 3000
    to_port          = 3000
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ecs_task_definition" "gotenberg-ecs-task" {
    family = "uoc-gotenberg-task-definition"
    network_mode = "awsvpc"
    requires_compatibilities = [ "FARGATE" ]
    memory = 1024
    cpu = 256
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
        container_definitions = <<EOF
    [
    {
        "name": "uoc-${var.app_env}-gotenberg-container-${var.uocenv}",
        "image": "thecodingmachine/gotenberg:6.4.0",
        "essential": true,
        "portMappings": [
        {   
            "protocol": "tcp",
            "containerPort": 80,
            "hostPort": 80
        }
        ]
    }
    ]
    EOF
}
