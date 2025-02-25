data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["iot.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iot_role" {
  name               = "iot-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "kinesis" {
  name   = "kinesis"
  role   = aws_iam_role.iot_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kinesis:*",
        ]
        Effect   = "Allow"
        Resource = var.kinesis_stream_arn
      },
    ]
  })
}

resource "aws_iot_topic_rule" "sample_topic" {
  name        = "SampleTopic"
  enabled     = true
  sql         = "SELECT * FROM 'device/data'"
  sql_version = "2016-03-23"
  
  kinesis {
    role_arn = aws_iam_role.iot_role.arn
    stream_name = var.kinesis_stream_name
  }
}
