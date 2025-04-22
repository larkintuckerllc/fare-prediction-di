resource "aws_glue_workflow" "fare_prediction" {
  name = "fare-prediction"
}

resource "aws_iam_policy" "fare_prediction_glue_notify_event" {
  name        = "fare-prediction-glue-notify-event"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:NotifyEvent"
        ]
        Resource = [
          aws_glue_workflow.fare_prediction.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role" "fare_prediction_eventbridge_glue_notify_event" {
  name = "fare-prediction-eventbridge-glue-notify-event"

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

resource "aws_iam_role_policy_attachment" "fare_prediction_eventbridge_glue_notify_event" {
  role       = aws_iam_role.fare_prediction_eventbridge_glue_notify_event.name
  policy_arn = aws_iam_policy.fare_prediction_glue_notify_event.arn
}

resource "aws_glue_trigger" "fare_prediction_eventbridge" {
  name          = "fare-prediction-eventbridge"
  type          = "EVENT"
  workflow_name = aws_glue_workflow.fare_prediction.name

  actions {
    job_name = aws_glue_job.fare_prediction.name
  }
}
