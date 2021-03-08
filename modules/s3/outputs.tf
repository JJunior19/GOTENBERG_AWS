output "in_bucket" {
  value = aws_s3_bucket.in_terraform_bucket.bucket
}
output "out_bucket" {
  value = aws_s3_bucket.out_terraform_bucket.bucket
}

output "in_bucket_id" {
  value = aws_s3_bucket.in_terraform_bucket.id
}

output "in_bucket_arn" {
  value = aws_s3_bucket.in_terraform_bucket.arn
}