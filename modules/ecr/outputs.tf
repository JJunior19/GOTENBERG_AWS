output "gotenberg-repository" {
    value = aws_ecr_repository.gotenberg-repository.arn
}
output "gotenbreg-repository-policy" {
    value = aws_ecr_repository_policy.gotenbreg-repository-policy
}