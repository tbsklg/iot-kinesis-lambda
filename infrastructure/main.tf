provider "aws" {
    region = "eu-central-1"
}

module "kinesis_stream" {
  source = "./modules/kinesis-stream"
}

module "kinesis_stream_consumer_lambda" {
  source = "./modules/consumer-lambda"
  kinesis_stream_arn = module.kinesis_stream.kinesis_stream_arn
}

module "iot_topic" {
  source = "./modules/iot-topic"
  kinesis_stream_arn = module.kinesis_stream.kinesis_stream_arn
  kinesis_stream_name = module.kinesis_stream.kinesis_stream_name
}
