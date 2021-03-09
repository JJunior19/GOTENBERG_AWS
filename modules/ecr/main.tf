data "aws_caller_identity" "current" {
}
data "aws_region" "region_current" {}
resource "aws_ecr_repository" "gotenberg-repository" {
    name = "uoc-${var.app_env}-gotenber-repository-${var.uocenv}"
    image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecr_repository_policy" "gotenbreg-repository-policy" {
    repository = aws_ecr_repository.gotenberg-repository.name
    policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}
resource "null_resource" "pull" {
    provisioner "local-exec"{
      command="docker pull ${var.docker_gotenberg}"
    }
}
resource "null_resource" "login" {
    provisioner "local-exec" {
        command="aws ecr get-login-password --region ${data.aws_region.region_current.name} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.region_current.name}.amazonaws.com"
    }
    depends_on = [ null_resource.pull]
}
resource "null_resource" "tag_image" {
    provisioner "local-exec" {
        command="docker tag ${var.docker_gotenberg} ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.region_current.name}.amazonaws.com/${aws_ecr_repository.gotenberg-repository.name}:latest"
    }
    depends_on = [ null_resource.login,
                    null_resource.pull
                  ]
}

resource "null_resource" "push_image" {
    provisioner "local-exec" {
        command = "docker push ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.region_current.name}.amazonaws.com/${aws_ecr_repository.gotenberg-repository.name}"
    }
    depends_on = [ 
                    null_resource.tag_image,
                    null_resource.login,
                    null_resource.pull
                ]
}