output "kinesis_stream_arn" {
    value       = aws_kinesis_stream.kinesis-stream.arn
    description = "kinesis_stream_arn"
}

output "kinesis_stream_name" {
    value       = aws_kinesis_stream.kinesis-stream.name
    description = "kinesis_stream_name"
}

