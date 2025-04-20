provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "fare_prediction" {
  bucket = "fare-prediction"
}

resource "aws_s3_bucket_lifecycle_configuration" "raw_folder_expiration" {
  bucket = aws_s3_bucket.fare_prediction.id

  rule {
    id     = "raw_folder_expiration"
    status = "Enabled"

    filter {
      prefix = "raw/"
    }

    expiration {
      days = 7
    }
  }
}
