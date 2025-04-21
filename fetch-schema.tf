resource "aws_iam_policy" "fare_prediction_s3" {
  name        = "fare-prediction-s3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.fare_prediction.arn,
          "${aws_s3_bucket.fare_prediction.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "fare_prediction_crawler" {
  name = "AWSGlueServiceRole-fare-prediction-crawler"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service_role_policy" {
  role       = aws_iam_role.fare_prediction_crawler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "fare_prediction_crawler_s3_policy" {
  role       = aws_iam_role.fare_prediction_crawler.name
  policy_arn = aws_iam_policy.fare_prediction_s3.arn
}

resource "aws_glue_catalog_database" "fare_prediction" {
  name = "fare-prediction"
}

resource "aws_glue_crawler" "fare_prediction" {
  name          = "fare-prediction"
  database_name = aws_glue_catalog_database.fare_prediction.name
  role          = aws_iam_role.fare_prediction_crawler.arn

  s3_target {
    path = "s3://${aws_s3_bucket.fare_prediction.id}/raw/"
  }
} 
