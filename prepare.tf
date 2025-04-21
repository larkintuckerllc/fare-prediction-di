resource "aws_iam_policy" "fare_prediction_etl_s3" {
  name        = "fare-prediction-etl-s3"

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

resource "aws_iam_role" "fare_prediction_etl" {
  name = "AWSGlueServiceRole-fare-prediction-etl"

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

resource "aws_iam_role_policy_attachment" "fare_prediction_etl_glue_service" {
  role       = aws_iam_role.fare_prediction_etl.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "fare_prediction_etl_s3" {
  role       = aws_iam_role.fare_prediction_etl.name
  policy_arn = aws_iam_policy.fare_prediction_etl_s3.arn
}

resource "aws_glue_job" "fare_prediction" {
  execution_class   = "STANDARD"
  name              = "fare-prediction"
  role_arn          = aws_iam_role.fare_prediction_etl.arn
  glue_version      = "5.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  timeout           = 480

  command {
    script_location = "s3://${aws_s3_bucket.fare_prediction.id}/scripts/fare-prediction.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"           = "python"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-glue-datacatalog"          = "true"
    "--enable-observability-metrics"     = "true"
    "--enable-metrics"                   = "true"
    "--enable-spark-ui"                  = "true"
    "--spark-event-logs-path"            = "s3://${aws_s3_bucket.fare_prediction.id}/sparkHistoryLogs/"
    "--enable-job-insights"              = "true"
    "--job-bookmark-option"              = "job-bookmark-disable"
    "--TempDir"                          = "s3://${aws_s3_bucket.fare_prediction.id}/temporary/"
  }

  execution_property {
    max_concurrent_runs = 1
  }
}
