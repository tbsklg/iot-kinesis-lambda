data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "consumer_lambda_role" {
  name               = "consumer-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy" "kinesis" {
  name = "kinesis"
  role = aws_iam_role.consumer_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kinesis:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "consumer_lambda_basic_execution_policy_attachment" {
  role       = aws_iam_role.consumer_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


data "archive_file" "consumer_lambda_archive" {
  type        = "zip"
  source_file = "${path.module}/../../../target/lambda/consumer/bootstrap"
  output_path = "${path.module}/../../../target/dist/consumer.zip"

  depends_on = [null_resource.build_lambda]
}

resource "null_resource" "build_lambda" {
  triggers = {
    source_code_hash = filebase64sha256("${path.module}/../../../lambdas/consumer/src/main.rs")
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/../../../ && cargo lambda build --release -p consumer"
  }
}

resource "aws_lambda_function" "consumer" {
  filename      = data.archive_file.consumer_lambda_archive.output_path
  function_name = "kinesis_stream_consumer"
  role          = aws_iam_role.consumer_lambda_role.arn

  handler = "bootstrap"

  source_code_hash = data.archive_file.consumer_lambda_archive.output_base64sha256

  runtime = "provided.al2023"

  architectures = ["x86_64"]

  memory_size = 128
}

resource "aws_lambda_event_source_mapping" "kinesis_lambda_event_mapping" {
  batch_size                     = 10
  event_source_arn               = var.kinesis_stream_arn
  enabled                        = true 
  function_name                  = aws_lambda_function.consumer.arn
  starting_position              = "TRIM_HORIZON"
  bisect_batch_on_function_error = true
  maximum_retry_attempts         = 5
}
