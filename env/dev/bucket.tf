resource "aws_s3_bucket" "Sam" {
  bucket = "aws-304188066464-us-east-2-terraform-remote-state-sample"

  tags = {
    Name        = "SamBucket"
    Environment = "Dev"
  }
}
