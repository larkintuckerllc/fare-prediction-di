# resource "aws_iam_role" "fare_prediction_etl" {
#   name = "AWSGlueServiceRole-fare-prediction-etl"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "glue.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "fare_prediction_etl_glue_service_role_policy" {
#   role       = aws_iam_role.fare_prediction_etl.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
# }

# resource "aws_iam_role_policy_attachment" "fare_prediction_etl_s3" {
#   role       = aws_iam_role.fare_prediction_etl.name
#   policy_arn = aws_iam_policy.fare_prediction_s3.arn
# }
