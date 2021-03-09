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