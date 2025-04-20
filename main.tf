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

resource "aws_sns_topic" "fare_prediction" {
  name = "fare-prediction"
}

resource "aws_sns_topic_subscription" "fare_prediction_email" {
  topic_arn = aws_sns_topic.fare_prediction.arn
  protocol  = "email"
  endpoint  = "john@larkintuckerllc.com"
}

resource "aws_iam_policy" "eventbridge_sns_publish" {
  name        = "Amazon_EventBridge_Invoke_Sns_fare_prediction"
  description = "Policy that allows publishing to the fare-prediction SNS topic"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "${aws_sns_topic.fare_prediction.arn}"
      }
    ]
  })
}
