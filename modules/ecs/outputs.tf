# output "vpc_info" {
#     value = aws_vpc.gotenberg-vpc.id
# }
output "cluster_ecs" {
    value = aws_ecs_cluster.gotenberg_cluster.arn
}

# output "subnet_info" {
#     value = aws_subnet.gotenberg-subnet.id
# }
