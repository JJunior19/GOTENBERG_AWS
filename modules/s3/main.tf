resource "aws_s3_bucket" "in_terraform_bucket" {
  bucket = "uoc-${var.app_env}-incoming-${var.uocenv}"
  lifecycle_rule {
    id      = "expire"
    enabled = true
    expiration {
      days = 2
    }
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  } 
  tags = {
    ci          = var.app_env
    Departament = var.departament
    UOCEnv      = var.uocenv
  }
}

resource "aws_s3_bucket" "out_terraform_bucket" {
  lifecycle_rule {
    id      = "expire"
    enabled = true
    expiration {
      days = 2
    }
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  } 
  bucket = "uoc-${var.app_env}-done-${var.uocenv}"
  tags = {
    ci          = var.app_env
    Departament = var.departament
    UOCEnv      = var.uocenv
  }
}