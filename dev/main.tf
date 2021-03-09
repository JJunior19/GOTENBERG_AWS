provider "aws" {
  profile= "uoc"
  shared_credentials_file = "~/.aws/credentials"
  region= "eu-west-1"
}

module "s3" {
    source = "../modules/s3"
    app_env = "converter"
    uocenv = "dev"
    departament = "support-uoc"
}

module "ecr" {
  source = "../modules/ecr"
  app_env = "converter"
  uocenv = "dev"
  departament = "support-uoc"
  docker_gotenberg= "thecodingmachine/gotenberg"
}

module "ecs" {
  source = "../modules/ecs"
  app_env = "converter"
  uocenv = "dev"
  departament = "support-uoc"
  repository = module.ecr.gotenberg-repository
  depends_on = [ module.ecr ]
}
output "out_bucket" {
  value = module.s3.out_bucket
}

output "in_bucket" {
  value = module.s3.in_bucket
}

output "repository_name" {
  value = module.ecr.gotenberg-repository
}

output "cluster" {
  value = module.ecs.cluster_ecs
}

output "vpc" {
  value = module.ecs.vpc_info
}

output "subnet" {
  value = module.ecs.subnet_info
}