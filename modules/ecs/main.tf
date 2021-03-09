data "aws_region" "region_current" {}
data "aws_caller_identity" "current" {
}

resource "aws_ecs_cluster" "gotenberg_cluster" {
    name="uoc-${var.app_env}-gotenberg-cluster-${var.uocenv}"
}

resource "aws_vpc" "gotenberg-vpc" { 
  cidr_block = "10.0.0.0/16" 
  enable_dns_hostnames = true
  tags = {
    "Name" = "uoc-${var.app_env}-gotenberg-vpc-${var.uocenv}"
  }
}
resource "aws_nat_gateway" "gotenberg-natway" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.gotenberg-subnet-public.id
    tags = {
      "Name" = "uoc-${var.app_env}-gotenberg-natway-${var.uocenv}"
    }
    depends_on = [ aws_internet_gateway.gotenberg_igw ]
}
resource "aws_eip" "nat_eip" {
    vpc = true
    tags = {
      "Name" = "uoc-${var.app_env}-gotenberg-eip-nat-${var.uocenv}"
    }
}
resource "aws_network_interface" "private" {
    subnet_id = aws_subnet.gotenberg-subnet.id
    tags = {
      "Name" = "uoc-${var.app_env}-gotenberg-ENI-${var.uocenv}"
    }
}
resource "aws_internet_gateway" "gotenberg_igw" {
    vpc_id = aws_vpc.gotenberg-vpc.id
    tags = {
      "Name" = "uoc-${var.app_env}-gotenberg-IGW-${var.uocenv}"
    }
}
resource "aws_subnet" "gotenberg-subnet" {
    vpc_id = aws_vpc.gotenberg-vpc.id
    cidr_block = "10.0.1.0/24"
    tags = {
      "Name" = "uoc-${var.app_env}-gotenberg-subnet-${var.uocenv}"
    }
}

resource "aws_subnet" "gotenberg-subnet-public" {
    vpc_id = aws_vpc.gotenberg-vpc.id
    cidr_block = "10.0.0.0/24"
    tags = {
      "Name" = "uoc-${var.app_env}-gotenberg-subnet-${var.uocenv}"
    }
}
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.gotenberg-vpc.id
    tags = {
      "Name" = "uoc-${var.app_env}-gotenberg-route-table-${var.uocenv}"
    }

}
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.gotenberg-vpc.id
    tags = {
      "Name" = "uoc-${var.app_env}-gotenberg-route-table-public-${var.uocenv}"
    }
}
resource "aws_route" "public" {
    route_table_id         = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.gotenberg_igw.id
}
resource "aws_route" "private" {
    route_table_id = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gotenberg-natway.id
}

resource "aws_route_table_association" "private" {
    subnet_id = aws_subnet.gotenberg-subnet.id
    route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.gotenberg-subnet-public.id
  route_table_id = aws_route_table.public.id
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
      subnets=[aws_subnet.gotenberg-subnet.id]
      assign_public_ip=true
    }
    desired_count = 1
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
        "image": "262477611921.dkr.ecr.eu-west-1.amazonaws.com/uoc-converter-gotenber-repository-dev:latest",
        "memory": 1024,
        "cpu": 256,
        "essential": true,
        "portMappings": [
        {   
            "protocol": "tcp",
            "containerPort": 3000,
            "hostPort": 3000
        }
        ]
    }
    ]
    EOF
}