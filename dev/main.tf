provider "aws" {
  profile= "default"
  shared_credentials_file = "../credentials"
  region= "us-east-1"
}

module "s3" {
    source = "../modules/s3"
    app_env = "converter"
    uocenv = "test"
    departament = "uoc-it"
}

output "out_bucket" {
  value = module.s3.out_bucket
}

output "in_bucket" {
  value = module.s3.in_bucket
}