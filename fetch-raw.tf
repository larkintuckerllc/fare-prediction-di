resource "aws_s3_bucket" "fare_prediction" {
  bucket = "fare-prediction"
}

resource "aws_s3_bucket_lifecycle_configuration" "fare_prediction_raw_folder_expiration" {
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

resource "aws_s3_bucket_notification" "fare_prediction" {
  bucket = aws_s3_bucket.fare_prediction.id

  eventbridge = true
}

resource "aws_sns_topic" "fare_prediction" {
  name = "fare-prediction"
}

resource "aws_sns_topic_subscription" "fare_prediction_email" {
  topic_arn = aws_sns_topic.fare_prediction.arn
  protocol  = "email"
  endpoint  = "john@larkintuckerllc.com"
}

resource "aws_iam_policy" "fare_prediction_sns_publish" {
  name        = "fare-prediction-sns-publish"

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

resource "aws_iam_role" "fare_prediction_eventbridge_sns_publish" {
  name = "fare-prediction-eventbridge-sns-publish"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fare_prediction_eventbridge_sns_publish" {
  role       = aws_iam_role.fare_prediction_eventbridge_sns_publish.name
  policy_arn = aws_iam_policy.fare_prediction_sns_publish.arn
}

resource "aws_cloudwatch_event_rule" "fare_prediction_s3_object_created" {
  name        = "fare-prediction-s3-object-created"

  event_pattern = jsonencode({
    "source": ["aws.s3"],
    "detail-type": ["Object Created"],
    "detail": {
      "bucket": {
        "name": [aws_s3_bucket.fare_prediction.id]
      },
      "object": {
        "key": [{"prefix": "raw/"}]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "fare_prediction_s3_object_created_sns_publish" {
  rule      = aws_cloudwatch_event_rule.fare_prediction_s3_object_created.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.fare_prediction.arn
  role_arn  = aws_iam_role.fare_prediction_eventbridge_sns_publish.arn
}
